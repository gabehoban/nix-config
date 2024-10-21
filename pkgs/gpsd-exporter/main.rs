// Source: (gpsd_proto) https://github.com/bwolf/gpsd_proto
// License: https://www.apache.org/licenses/LICENSE-2.0
//
// Significant Changes:
// - Added missing TVP keys
// - Add prometheus server for getting GPSD metrics

extern crate log;

#[macro_use]
extern crate serde_derive;

use std::fmt;
use std::io;
use std::net::TcpStream;
use std::sync::mpsc::{channel, Sender};
use std::thread;

use hyper::{
    header::CONTENT_TYPE,
    server::Server,
    service::{make_service_fn, service_fn},
    Body, Request, Response,
};
use lazy_static::lazy_static;
use prometheus::{Encoder, GaugeVec, IntGaugeVec, TextEncoder};

use log::{error, info, trace};
use serde::de::*;
use serde::Deserializer;

/// Minimum supported version of `gpsd`.
pub const PROTO_MAJOR_MIN: u8 = 3;

/// Command to enable watch.
pub const ENABLE_WATCH_CMD: &str = "?WATCH={\"enable\":true,\"json\":true};\r\n";

lazy_static! {
    static ref GAUGE_GDOP: GaugeVec = prometheus::register_gauge_vec!("gpsd_gdop", "Geometric (hyperspherical) dilution of precision", &["object"]).unwrap();
    static ref GAUGE_HDOP: GaugeVec = prometheus::register_gauge_vec!("gpsd_hdop", "Horizontal dilution of precision", &["object"]).unwrap();
    static ref GAUGE_PDOP: GaugeVec = prometheus::register_gauge_vec!("gpsd_pdop", "Position (spherical/3D) dilution of precision", &["object"]).unwrap();
    static ref GAUGE_TDOP: GaugeVec = prometheus::register_gauge_vec!("gpsd_tdop", "Time dilution of precision", &["object"]).unwrap();
    static ref GAUGE_VDOP: GaugeVec = prometheus::register_gauge_vec!("gpsd_vdop", "Vertical (altitude) dilution of precision", &["object"]).unwrap();
    static ref GAUGE_YDOP: GaugeVec = prometheus::register_gauge_vec!("gpsd_ydop", "Latitudinal dilution of precision", &["object"]).unwrap();
    static ref GAUGE_XDOP: GaugeVec = prometheus::register_gauge_vec!("gpsd_xdop", "Longitudinal dilution of precision", &["object"]).unwrap();
    static ref GAUGE_NSAT: GaugeVec = prometheus::register_gauge_vec!("gpsd_nSat", "Number of satellite objects in 'satellites' array", &["object"]).unwrap();
    static ref GAUGE_USAT: GaugeVec = prometheus::register_gauge_vec!("gpsd_uSat", "Number of satellite objects used in solution", &["object"]).unwrap();
    static ref GAUGE_LAT: GaugeVec = prometheus::register_gauge_vec!("gpsd_lat", "Latitude in degrees: +/- signifies North/South", &["object"]).unwrap();
    static ref GAUGE_LONG: GaugeVec = prometheus::register_gauge_vec!("gpsd_long", "Longitude in degrees: +/- signifies East/West", &["object"]).unwrap();
    static ref GAUGE_ALTHAE: GaugeVec = prometheus::register_gauge_vec!("gpsd_altHAE", "Altitude, height above ellipsoid, in meters", &["object"]).unwrap();
    static ref GAUGE_ALTMSL: GaugeVec = prometheus::register_gauge_vec!("gpsd_altMSL", "MSL Altitude in meters", &["object"]).unwrap();
    static ref GAUGE_STATUS: IntGaugeVec = prometheus::register_int_gauge_vec!("gpsd_status", "GPS fix status", &["object"]).unwrap();
    static ref GAUGE_LEAP: GaugeVec = prometheus::register_gauge_vec!("gpsd_leapseconds", "Current leap seconds", &["object"]).unwrap();
    static ref GAUGE_MAGVAR: GaugeVec = prometheus::register_gauge_vec!("gpsd_magvar", "Magnetic variation, degrees", &["object"]).unwrap();
    static ref GAUGE_EPT: GaugeVec = prometheus::register_gauge_vec!("gpsd_ept", "Estimated time stamp error in seconds", &["object"]).unwrap();
    static ref GAUGE_EPX: GaugeVec = prometheus::register_gauge_vec!("gpsd_epx", "Longitude error estimate in meters", &["object"]).unwrap();
    static ref GAUGE_EPY: GaugeVec = prometheus::register_gauge_vec!("gpsd_epy", "Latitude error estimate in meters", &["object"]).unwrap();
    static ref GAUGE_EPV: GaugeVec = prometheus::register_gauge_vec!("gpsd_epv", "Estimated vertical error in meters", &["object"]).unwrap();
    static ref GAUGE_EPS: GaugeVec = prometheus::register_gauge_vec!("gpsd_eps", "Estimated speed error in meters per second", &["object"]).unwrap();
    static ref GAUGE_EPC: GaugeVec = prometheus::register_gauge_vec!("gpsd_epc", "Estimated climb error in meters per second", &["object"]).unwrap();
    static ref GAUGE_GEOIDSEP: GaugeVec = prometheus::register_gauge_vec!("gpsd_geoidSep", "Geoid separation is the difference between the WGS84 reference ellipsoid and the geoid", &["object"]).unwrap();
    static ref GAUGE_EPH: GaugeVec = prometheus::register_gauge_vec!("gpsd_eph", "Estimated horizontal Position (2D) Error in meters", &["object"]).unwrap();
    static ref GAUGE_SEP: GaugeVec = prometheus::register_gauge_vec!("gpsd_sep", "Estimated Spherical (3D) Position Error in meters", &["object"]).unwrap();
    static ref GAUGE_ECEFX: GaugeVec = prometheus::register_gauge_vec!("gpsd_ecefx", "ECEF X position in meters", &["object"]).unwrap();
    static ref GAUGE_ECEFY: GaugeVec = prometheus::register_gauge_vec!("gpsd_ecefy", "ECEF Y position in meters", &["object"]).unwrap();
    static ref GAUGE_ECEFZ: GaugeVec = prometheus::register_gauge_vec!("gpsd_ecefz", "ECEF Z position in meters", &["object"]).unwrap();
    static ref GAUGE_ECEFVX: GaugeVec = prometheus::register_gauge_vec!("gpsd_ecefvx", "ECEF X velocity in meters per second", &["object"]).unwrap();
    static ref GAUGE_ECEFVY: GaugeVec = prometheus::register_gauge_vec!("gpsd_ecefvy", "ECEF Y velocity in meters per second", &["object"]).unwrap();
    static ref GAUGE_ECEFVZ: GaugeVec = prometheus::register_gauge_vec!("gpsd_ecefvz", "ECEF Z velocity in meters per second", &["object"]).unwrap();
    static ref GAUGE_ECEFPACC: GaugeVec = prometheus::register_gauge_vec!("gpsd_ecefpAcc", "ECEF velocity error in meters per second. Certainty unknown", &["object"]).unwrap();
    static ref GAUGE_VELN: GaugeVec = prometheus::register_gauge_vec!("gpsd_velN", "North velocity component in meters", &["object"]).unwrap();
    static ref GAUGE_VELE: GaugeVec = prometheus::register_gauge_vec!("gpsd_velE", "East velocity component in meters", &["object"]).unwrap();
    static ref GAUGE_VELD: GaugeVec = prometheus::register_gauge_vec!("gpsd_velD", "Down velocity component in meters", &["object"]).unwrap();
}

/// `gpsd` ships a VERSION response to each client when the client
/// first connects to it.
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
pub struct Version {
    pub release: String,
    pub rev: String,
    pub proto_major: u8,
    pub proto_minor: u8,
    pub remote: Option<String>,
}

/// Device information (i.e. device enumeration).
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
pub struct Devices {
    pub devices: Vec<DeviceInfo>,
}
/// Single device information as reported by `gpsd`.
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
pub struct DeviceInfo {
    pub path: Option<String>,
    pub activated: Option<String>,
}

/// Watch response. Elicits a report of per-subscriber policy.
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
pub struct Watch {
    pub enable: Option<bool>,
    pub json: Option<bool>,
    pub nmea: Option<bool>,
    pub raw: Option<u8>,
    pub scaled: Option<bool>,
    pub timing: Option<bool>,
    pub split24: Option<bool>,
    pub pps: Option<bool>,
}

/// Responses from `gpsd` during handshake..
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
#[serde(tag = "class")]
#[serde(rename_all = "UPPERCASE")]
pub enum ResponseHandshake {
    Version(Version),
    Devices(Devices),
    Watch(Watch),
}

/// Device information.
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
pub struct Device {
    pub path: Option<String>,
    pub activated: Option<String>,
    pub flags: Option<i32>,
    pub driver: Option<String>,
    pub subtype: Option<String>,
    pub bps: Option<u16>,
    pub parity: Option<String>,
    pub stopbits: Option<u8>,
    pub native: Option<u8>,
    pub cycle: Option<f32>,
    pub mincycle: Option<f32>,
}

/// Type of GPS fix.
#[derive(Debug, Copy, Clone)]
pub enum Mode {
    NoFix,
    Fix2d,
    Fix3d,
}

impl fmt::Display for Mode {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Mode::NoFix => write!(f, "NoFix"),
            Mode::Fix2d => write!(f, "2d"),
            Mode::Fix3d => write!(f, "3d"),
        }
    }
}

fn mode_from_str<'de, D>(deserializer: D) -> Result<Mode, D::Error>
where
    D: Deserializer<'de>,
{
    let s = u8::deserialize(deserializer)?;
    match s {
        2 => Ok(Mode::Fix2d),
        3 => Ok(Mode::Fix3d),
        _ => Ok(Mode::NoFix),
    }
}

/// GPS position.
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
pub struct Tpv {
    pub device: Option<String>,
    pub status: Option<i32>,
    #[serde(deserialize_with = "mode_from_str")]
    pub mode: Mode,
    pub time: Option<String>,
    pub ept: Option<f32>,
    pub leapseconds: Option<i32>,
    #[serde(rename = "altMSL")]
    pub alt_msl: Option<f32>,
    #[serde(rename = "altHAE")]
    pub alt_hae: Option<f32>,
    #[serde(rename = "geoidSep")]
    pub geoid_sep: Option<f32>,
    pub lat: Option<f64>,
    pub lon: Option<f64>,
    pub alt: Option<f32>,
    pub epx: Option<f32>,
    pub epy: Option<f32>,
    pub epv: Option<f32>,
    pub track: Option<f32>,
    pub speed: Option<f32>,
    pub climb: Option<f32>,
    pub epd: Option<f32>,
    pub eps: Option<f32>,
    pub epc: Option<f32>,
    pub eph: Option<f32>,
    pub ecefx: Option<f32>,
    pub ecefy: Option<f32>,
    pub ecefz: Option<f32>,
    pub ecefvx: Option<f32>,
    pub ecefvy: Option<f32>,
    pub ecefvz: Option<f32>,
    pub ecefpacc: Option<f32>,
    pub veln: Option<f32>,
    pub vele: Option<f32>,
    pub veld: Option<f32>,
}

/// Detailed satellite information.
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
pub struct Satellite {
    #[serde(rename = "PRN")]
    pub prn: i16,
    pub el: Option<f32>,
    pub az: Option<f32>,
    pub ss: Option<f32>,
    pub used: bool,
    pub gnssid: Option<u8>,
    pub svid: Option<u16>,
    pub health: Option<u8>,
}

/// Satellites information.
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
pub struct Sky {
    pub device: Option<String>,
    pub xdop: Option<f32>,
    pub ydop: Option<f32>,
    pub vdop: Option<f32>,
    pub tdop: Option<f32>,
    pub hdop: Option<f32>,
    pub gdop: Option<f32>,
    pub pdop: Option<f32>,
    pub satellites: Option<Vec<Satellite>>,
}

/// This message is emitted each time the daemon sees a valid PPS (Pulse Per
/// Second) strobe from a device.
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
pub struct Pps {
    pub device: String,
    pub real_sec: f32,
    pub real_nsec: f32,
    pub clock_sec: f32,
    pub clock_nsec: f32,
    pub precision: f32,
}

/// Pseudorange noise report.
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
pub struct Gst {
    pub device: Option<String>,
    pub time: Option<String>,
    pub rms: Option<f32>,
    pub major: Option<f32>,
    pub minor: Option<f32>,
    pub orient: Option<f32>,
    pub lat: Option<f32>,
    pub lon: Option<f32>,
    pub alt: Option<f32>,
}

/// Responses from `gpsd` after handshake (i.e. the payload)
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
#[serde(tag = "class")]
#[serde(rename_all = "UPPERCASE")]
pub enum ResponseData {
    Device(Device),
    Tpv(Tpv),
    Sky(Sky),
    Pps(Pps),
    Gst(Gst),
}

/// All known `gpsd` responses (handshake + normal operation).
#[derive(Debug, Deserialize, Clone)]
#[cfg_attr(feature = "serialize", derive(Serialize))]
#[serde(tag = "class")]
#[serde(rename_all = "UPPERCASE")]
pub enum UnifiedResponse {
    Version(Version),
    Devices(Devices),
    Watch(Watch),
    Device(Device),
    Tpv(Tpv),
    Sky(Sky),
    Pps(Pps),
    Gst(Gst),
}

/// Errors during handshake or data acquisition.
#[derive(Debug)]
pub enum GpsdError {
    IoError(io::Error),
    JsonError(serde_json::Error),
    UnsupportedGpsdProtocolVersion,
    UnexpectedGpsdReply(String),
    WatchFail(String),
}

impl From<io::Error> for GpsdError {
    fn from(err: io::Error) -> GpsdError {
        GpsdError::IoError(err)
    }
}

impl From<serde_json::Error> for GpsdError {
    fn from(err: serde_json::Error) -> GpsdError {
        GpsdError::JsonError(err)
    }
}

impl fmt::Display for GpsdError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            GpsdError::IoError(e) => write!(f, "IoError: {}", e),
            GpsdError::JsonError(e) => write!(f, "JsonError: {}", e),
            GpsdError::UnsupportedGpsdProtocolVersion => {
                write!(f, "UnsupportedGpsdProtocolVersion")
            }
            GpsdError::UnexpectedGpsdReply(e) => write!(f, "UnexpectedGpsdReply: {}", e),
            GpsdError::WatchFail(e) => write!(f, "WatchFail: {}", e),
        }
    }
}

/// Performs the initial handshake with `gpsd`.
pub fn handshake(reader: &mut dyn io::BufRead, writer: &mut dyn io::Write) -> Result<(), GpsdError> {
    let mut data = Vec::new();
    reader.read_until(b'\n', &mut data)?;
    trace!("{}", String::from_utf8(data.clone()).unwrap());
    let msg: ResponseHandshake = serde_json::from_slice(&data)?;
    match msg {
        ResponseHandshake::Version(v) => {
            if v.proto_major < PROTO_MAJOR_MIN {
                return Err(GpsdError::UnsupportedGpsdProtocolVersion);
            }
        }
        _ => return Err(GpsdError::UnexpectedGpsdReply(String::from_utf8(data).unwrap())),
    }

    // Enable WATCH
    writer.write_all(ENABLE_WATCH_CMD.as_bytes())?;
    writer.flush()?;

    // Get DEVICES
    let mut data = Vec::new();
    reader.read_until(b'\n', &mut data)?;
    trace!("{}", String::from_utf8(data.clone()).unwrap());
    let msg: ResponseHandshake = serde_json::from_slice(&data)?;
    match msg {
        ResponseHandshake::Devices(_) => {}
        _ => return Err(GpsdError::UnexpectedGpsdReply(String::from_utf8(data).unwrap())),
    }

    // Get WATCH
    let mut data = Vec::new();
    reader.read_until(b'\n', &mut data)?;
    trace!("{}", String::from_utf8(data.clone()).unwrap());
    let msg: ResponseHandshake = serde_json::from_slice(&data)?;
    match msg {
        ResponseHandshake::Watch(w) => {
            if let (false, false, true) = (w.enable.unwrap_or(false), w.json.unwrap_or(false), w.nmea.unwrap_or(false)) {
                return Err(GpsdError::WatchFail(String::from_utf8(data).unwrap()));
            }
        }
        _ => return Err(GpsdError::UnexpectedGpsdReply(String::from_utf8(data).unwrap())),
    }

    Ok(())
}

/// Get one payload entry from `gpsd`.
pub fn get_data(reader: &mut dyn io::BufRead) -> Result<ResponseData, GpsdError> {
    let mut data = Vec::new();
    reader.read_until(b'\n', &mut data)?;
    trace!("{}", String::from_utf8(data.clone()).unwrap());
    let msg: ResponseData = serde_json::from_slice(&data)?;
    Ok(msg)
}

pub fn measure_all<R>(_tx: Sender<i32>, mut reader: &mut dyn io::BufRead, writer: &mut io::BufWriter<R>) -> Result<(), GpsdError>
where
    R: std::io::Write,
{
    handshake(reader, writer).unwrap();
    loop {
        let msg = get_data(&mut reader).unwrap();
        match msg {
            ResponseData::Sky(sky) => {
                GAUGE_GDOP.with_label_values(&["SKY"]).set(sky.gdop.unwrap_or(0.0) as f64);
                GAUGE_HDOP.with_label_values(&["SKY"]).set(sky.hdop.unwrap_or(0.0) as f64);
                GAUGE_PDOP.with_label_values(&["SKY"]).set(sky.pdop.unwrap_or(0.0) as f64);
                GAUGE_TDOP.with_label_values(&["SKY"]).set(sky.tdop.unwrap_or(0.0) as f64);
                GAUGE_VDOP.with_label_values(&["SKY"]).set(sky.vdop.unwrap_or(0.0) as f64);
                GAUGE_YDOP.with_label_values(&["SKY"]).set(sky.ydop.unwrap_or(0.0) as f64);
                GAUGE_XDOP.with_label_values(&["SKY"]).set(sky.xdop.unwrap_or(0.0) as f64);
                if sky.satellites.is_some() {
                    GAUGE_NSAT.with_label_values(&["SKY"]).set(sky.satellites.as_ref().unwrap().len() as f64);
                    GAUGE_USAT.with_label_values(&["SKY"]).set(sky.satellites.map_or_else(|| 0, |sats| sats.iter().filter(|sat| sat.used).map(|_| 1).sum()) as f64);
                }
            }
            ResponseData::Tpv(tpv) => {
                GAUGE_LAT.with_label_values(&["TPV"]).set(tpv.lat.unwrap_or(0.0) as f64);
                GAUGE_LONG.with_label_values(&["TPV"]).set(tpv.lon.unwrap_or(0.0) as f64);
                GAUGE_ALTHAE.with_label_values(&["TPV"]).set(tpv.alt_hae.unwrap_or(0.0) as f64);
                GAUGE_ALTMSL.with_label_values(&["TPV"]).set(tpv.alt_msl.unwrap_or(0.0) as f64);
                GAUGE_STATUS.with_label_values(&["TPV"]).set(tpv.status.unwrap_or(0) as i64);
                GAUGE_EPT.with_label_values(&["TPV"]).set(tpv.ept.unwrap_or(0.0) as f64);
                GAUGE_EPX.with_label_values(&["TPV"]).set(tpv.epx.unwrap_or(0.0) as f64);
                GAUGE_EPY.with_label_values(&["TPV"]).set(tpv.epy.unwrap_or(0.0) as f64);
                GAUGE_EPV.with_label_values(&["TPV"]).set(tpv.epv.unwrap_or(0.0) as f64);
                GAUGE_EPS.with_label_values(&["TPV"]).set(tpv.eps.unwrap_or(0.0) as f64);
                GAUGE_EPC.with_label_values(&["TPV"]).set(tpv.epc.unwrap_or(0.0) as f64);
                GAUGE_GEOIDSEP.with_label_values(&["TPV"]).set(tpv.geoid_sep.unwrap_or(0.0) as f64);
                GAUGE_EPH.with_label_values(&["TPV"]).set(tpv.eph.unwrap_or(0.0) as f64);
                GAUGE_ECEFX.with_label_values(&["TPV"]).set(tpv.ecefx.unwrap_or(0.0) as f64);
                GAUGE_ECEFY.with_label_values(&["TPV"]).set(tpv.ecefy.unwrap_or(0.0) as f64);
                GAUGE_ECEFZ.with_label_values(&["TPV"]).set(tpv.ecefz.unwrap_or(0.0) as f64);
                GAUGE_ECEFVX.with_label_values(&["TPV"]).set(tpv.ecefvx.unwrap_or(0.0) as f64);
                GAUGE_ECEFVY.with_label_values(&["TPV"]).set(tpv.ecefvy.unwrap_or(0.0) as f64);
                GAUGE_ECEFVZ.with_label_values(&["TPV"]).set(tpv.ecefvz.unwrap_or(0.0) as f64);
                GAUGE_ECEFPACC.with_label_values(&["TPV"]).set(tpv.ecefpacc.unwrap_or(0.0) as f64);
                GAUGE_VELN.with_label_values(&["TPV"]).set(tpv.veln.unwrap_or(0.0) as f64);
                GAUGE_VELE.with_label_values(&["TPV"]).set(tpv.vele.unwrap_or(0.0) as f64);
                GAUGE_VELD.with_label_values(&["TPV"]).set(tpv.veld.unwrap_or(0.0) as f64);
            }
            ResponseData::Pps(_pps) => {}
            ResponseData::Gst(_gst) => {}
            ResponseData::Device(_device) => {}
        }
    }
}

async fn serve_req(_req: Request<Body>) -> Result<Response<Body>, hyper::Error> {
    let encoder = TextEncoder::new();

    let metric_families = prometheus::gather();
    let mut buffer = vec![];
    encoder.encode(&metric_families, &mut buffer).unwrap();

    let response = Response::builder().status(200).header(CONTENT_TYPE, encoder.format_type()).body(Body::from(buffer)).unwrap();

    Ok(response)
}

#[tokio::main]
async fn main() {
    env_logger::init();
    let addr = ([0, 0, 0, 0], 9101).into();

    let (tx, _) = channel();
    if let Ok(stream) = TcpStream::connect("127.0.0.1:2947") {
        thread::spawn(move || {
            let mut reader = io::BufReader::new(&stream);
            let mut writer = io::BufWriter::new(&stream);

            match measure_all(tx, &mut reader, &mut writer) {
                Ok(_) => info!("all measure success"),
                _ => error!("error!!!"),
            }
        });
    } else {
        panic!("Couldn't connect to gpsd...");
    }
    let serve_future = Server::bind(&addr).serve(make_service_fn(|_| async { Ok::<_, hyper::Error>(service_fn(serve_req)) }));
    if let Err(err) = serve_future.await {
        error!("server error: {}", err);
    }
}
