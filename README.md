# Socat LG Therma V Bridge

A local Home Assistant add-on that connects a TCP-to-serial gateway (such as the **ATOP SE5201-DB**) to a virtual serial device in Home Assistant using **socat**.

Designed for an **LG Therma V** heat pump connected over **RS485 / Modbus RTU**. This add-on is a transparent transport bridge: it **does not** interpret Modbus registers or control the heat pump by itself.

## How it works

```text
LG Therma V (RS485 / Modbus RTU)
             |
             v
ATOP SE5201-DB (RAW TCP server, port 4660)
             |
             v
Home Assistant add-on (socat TCP <-> PTY)
             |
             v
/config/ttyLG (virtual serial device)
             |
             v
Home Assistant Modbus RTU configuration
```

## Requirements

- Home Assistant installation with support for local add-ons (Home Assistant OS or Supervised).
- A TCP-to-RS485 gateway configured for transparent **RAW TCP** forwarding.
- An LG Therma V installation with RS485/Modbus RTU configured correctly.
- A separate Home Assistant Modbus configuration that uses the virtual serial port.

> **Important:** A plain Home Assistant Container installation does not provide the add-on manager.

## Installation

1. Copy this repository's files to a folder named `socat_lg` inside your Home Assistant **local add-ons** directory.
2. In Home Assistant, go to **Settings > Add-ons > Add-on Store**.
3. Refresh/reload the add-on store so the local add-on is discovered.
4. Install **Socat LG Therma V bridge**.
5. Configure the gateway address and start the add-on.
6. Check the add-on log for the TCP connection and PTY link.

Example local add-on folder structure:

```text
addons/local/socat_lg/
├── config.yaml
├── Dockerfile
└── rootfs/
    └── etc/
        └── services.d/
            └── socat/
                └── run
```

The host-side location of the add-ons directory varies by installation; use the local add-on directory of your Home Assistant Supervisor data folder.

## Configuration

Open **Settings > Add-ons > Socat LG Therma V bridge > Configuration**.

Example:

```yaml
host: "192.168.1.3"
port: 4660
link: "/config/ttyLG"
```

| Option | Purpose |
| --- | --- |
| `host` | IP address or hostname of the TCP-to-serial gateway |
| `port` | TCP listening port of the gateway (example: `4660`) |
| `link` | Virtual serial-device symlink created by `socat` (default: `/config/ttyLG`) |

The IP address shown here is an **example**. Use the address configured for your own gateway. The `host` value in `config.yaml` is only the add-on's default; the values saved in the Home Assistant add-on Configuration page are used at runtime.

## Gateway settings

Example settings for an ATOP SE5201-DB connected to an LG Therma V:

| Setting | Value |
| --- | --- |
| Link mode | TCP Server |
| Application | RAW |
| Local port | 4660 |
| Serial interface | RS485 2-wire |
| Baud rate | 9600 |
| Data bits | 8 |
| Parity | None |
| Stop bits | 1 |
| Response behavior | Transparent Mode |

Verify the serial settings against your heat pump's actual Modbus configuration.

**Do not change the gateway to Modbus TCP mode** for this add-on: it forwards raw Modbus RTU bytes through a TCP connection.

## Implementation

The add-on reads its settings from `/data/options.json` and runs:

```sh
exec socat -d -d "tcp:${HOST}:${PORT}" "pty,raw,echo=0,link=${LINK}"
```

The add-on installs `socat` and `jq` in its container. Its add-on metadata specifies automatic startup and maps the Home Assistant configuration directory read/write.

## Modbus configuration

This repository contains **only the transport bridge**. Configure Modbus RTU separately in Home Assistant, using the virtual device path `/config/ttyLG` where accessible to the Modbus integration. The required Modbus registers, slave address, and control logic are not included in this repository.

> **Compatibility note:** A PTY created inside an add-on container is not automatically guaranteed to be usable from another container merely because a symlink exists in `/config`. Verify that the device target is accessible from the Home Assistant process in your installation. This repository documents the existing bridge implementation; it does not guarantee cross-container PTY visibility on every Home Assistant version.

## Troubleshooting

- **Cannot connect:** Check the gateway IP, TCP port, firewall, and whether another client is using the gateway.
- **No sensor updates:** Check RS485 wiring, serial parameters, Modbus slave address, and the separate Modbus configuration.
- **`/config/ttyLG` missing or unusable:** Check the add-on logs and whether the PTY is accessible to the process that opens it.
- **Unreliable communication:** Avoid concurrent Modbus masters on the same RS485 bus. A gateway accepting multiple TCP clients does **not** make simultaneous Modbus RTU requests safe.

## Security

- Keep the gateway and its RAW TCP port on a trusted local network; RAW TCP provides no encryption or authentication by itself.
- Do not expose port `4660` directly to the internet.
- Do not commit passwords, tokens, or live Home Assistant configuration files to this repository.
- Test control-register changes carefully; incorrect commands can affect heating operation.

## Project status

Local Home Assistant add-on, version **1.0.0** (as declared in `config.yaml`). Intended for an existing LG Therma V / ATOP SE5201-DB setup.

## License

No license is included in the current add-on files. Add a `LICENSE` file if you decide to publish this project for reuse.
