# Socat LG Therma V bridge

Home Assistant **local add-on** connecting a Modbus RTU-over-RS485 LG Therma V heat pump to Home Assistant through an **ATOP SE5201** serial-to-Ethernet gateway.

## Data path

`LG RS485 (Modbus RTU) -> ATOP (RAW TCP) -> socat -> /config/ttyLG -> Home Assistant Modbus RTU`

This add-on **does not** convert Modbus RTU to Modbus TCP and does **not** implement heat-pump control logic.

## Installation

1. Back up the current `socat_lg` folder and Home Assistant configuration.
2. Copy the `socat_lg` folder into the Home Assistant local add-ons directory (often `/addons/socat_lg` inside HA, or `<supervisor-data>/addons/local/socat_lg` on the host).
3. In Home Assistant, go to **Settings > Add-ons > Add-on Store**, refresh/reload local add-ons if needed, and open **Socat LG Therma V bridge**.
4. Review the configuration and rebuild/reinstall the add-on image when upgrading the local add-on; then restart it.
5. Check the add-on logs and verify Modbus readings in Home Assistant.

## Configuration

```yaml
host: 192.168.1.3
port: 4660
link: /config/ttyLG
```

The host above is an **example**. Keep the IP address that works in your current add-on configuration. Defaults in `config.yaml` are not necessarily the active settings.

Configure the ATOP for **TCP Server**, **RAW**, **Transparent Mode**, and the correct serial settings for the LG (in the author's installation: RS485 2-wire, 9600 8N1). Use **Modbus RTU** against `/config/ttyLG` in Home Assistant.

## Improvements in v1.1.0

- Reconnects 5 seconds after socat exits (for example, following a TCP disconnect).
- Enables TCP keepalive and a 10-second connection timeout.
- Adds timestamped connection and reconnect logs.
- Validates host, port and PTY link settings.
- Preserves the existing `host`, `port` and `link` configuration options.

## Limitations and safety

- TCP keepalive is **not** a Modbus health check. Check actual LG sensor updates in Home Assistant.
- If the PTY is recreated, a Modbus integration holding the old file descriptor may need to reconnect or be reloaded.
- Do not connect two independent Modbus masters to the ATOP at the same time.
- RAW TCP is unencrypted; keep the ATOP port on a trusted LAN/VPN, not exposed to the internet.
- Test the updated add-on while the heat pump can safely fall back to its own controller.

## Files

- `config.yaml`: Home Assistant add-on metadata and user options
- `Dockerfile`: image build
- `rootfs/etc/services.d/socat/run`: s6-managed socat bridge service
