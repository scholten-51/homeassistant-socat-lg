# Socat LG Therma V bridge

Home Assistant add-on repository for a RAW TCP to virtual serial (PTY) bridge for an LG Therma V heat pump through an ATOP SE5201 RS485-to-Ethernet gateway.

## Install from Home Assistant

1. Open **Settings > Add-ons > Add-on Store**.
2. Open **Repositories** and add:
   `https://github.com/scholten-51/homeassistant-socat-lg`
3. Refresh the Add-on Store, then install **Socat LG Therma V bridge**.
4. Configure the ATOP host IP, port, and serial link, then start the add-on.
5. Check the add-on logs and verify your existing Modbus RTU sensors still update.

Example add-on configuration:

```yaml
host: 192.168.1.3
port: 4660
link: /config/ttyLG
```

Use your actual ATOP address. ATOP should run **TCP Server / RAW / Transparent Mode**, with serial settings matching the LG (the original installation used RS485 2-wire, 9600 8N1).

## How it works

`LG RS485 Modbus RTU -> ATOP RAW TCP -> socat -> /config/ttyLG -> Home Assistant Modbus RTU`

This bridge does **not** convert RTU frames to Modbus TCP, and does **not** implement heat-pump control algorithms.

## Reliability improvements in v1.1.0

- Reconnect on TCP disconnect (5-second retry).
- TCP keepalive and connection timeout.
- Clear timestamped logs and configuration validation.
- Keeps the `host`, `port`, `link` options compatible with the local add-on.

**Important:** a recreated PTY can require Home Assistant's Modbus integration to reconnect. Avoid multiple simultaneous Modbus masters, and never expose the unencrypted ATOP TCP port to the internet.

The add-on has not yet been verified on every supported architecture. Please report issues on GitHub.

## Source files

The installable add-on is in [`socat_lg/`](socat_lg/). Its own [README](socat_lg/README.md) includes technical details.

## License

MIT — see [LICENSE](LICENSE).
