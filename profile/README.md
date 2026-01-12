<img src="https://github.com/beam-bots/bb/blob/main/logos/beam_bots_logo.png?raw=true" alt="Beam Bots Logo" width="250" />

[![CI](https://github.com/beam-bots/bb/actions/workflows/ci.yml/badge.svg)](https://github.com/beam-bots/bb/actions/workflows/ci.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache--2.0-green.svg)](https://opensource.org/licenses/Apache-2.0)
[![Hex version badge](https://img.shields.io/hexpm/v/bb.svg)](https://hex.pm/packages/bb)
[![REUSE status](https://api.reuse.software/badge/github.com/beam-bots/bb)](https://api.reuse.software/info/github.com/beam-bots/bb)

# Welcome to Beam Bots

Beam Bots is a framework for building resilient robotics projects in Elixir. Define robot topologies with a Spark DSL, get supervision trees that mirror your physical structure for fault isolation, and use forward/inverse kinematics with Nx tensors.

## Get Started

- [Your First Robot](https://hexdocs.pm/bb/01-first-robot.html) - defining robots with the DSL
- [DSL Reference](https://hexdocs.pm/bb/dsl-bb.html) - all available options
- [Proposals](https://github.com/beam-bots/proposals) - planned features and roadmap

## Ecosystem

- [`bb`](https://github.com/beam-bots/bb) - Core framework
- [`bb_kino`](https://github.com/beam-bots/bb_kino) - Livebook widgets for robot control and visualisation
- [`bb_liveview`](https://github.com/beam-bots/bb_liveview) - Phoenix LiveView dashboard
- [`bb_ik_fabrik`](https://github.com/beam-bots/bb_ik_fabrik) - FABRIK inverse kinematics solver
- [`bb_servo_pca9685`](https://github.com/beam-bots/bb_servo_pca9685) - PCA9685 PWM servo driver
- [`bb_servo_pigpio`](https://github.com/beam-bots/bb_servo_pigpio) - pigpio servo driver (Raspberry Pi)
- [`bb_servo_robotis`](https://github.com/beam-bots/bb_servo_robotis) - Robotis/Dynamixel servo driver
