![GitHub all releases](https://img.shields.io/github/downloads/NeonScriptsAU/neon_sellshop/total?color=blue&style=flat-square)

# Neon Sell Shop for ESX, QBCore & QBOX

## Overview

The Neon Sell Shop script provides an interactive selling system for FiveM servers using either the ESX, QBCore, or QBOX framework. This script dynamically adapts to the selected framework and allows players to sell materials or items for in-game currency, with fully configurable shop settings.

## Setup

1. **Framework Selection**:
   - Open `config.lua` and set the framework you're using:
     ```lua
     Config.Framework = 'ESX' -- Set this to 'ESX', 'QB', or 'QBX' depending on your framework.
     ```

2. **Shop Customization**:
   - Define your shop locations, items, and prices in the `config.lua` file:
     ```lua
     Config.Shops = {
         {
             label = "Material Buyer",
             pedModel = 's_m_m_autoshop_02',
             pedCoords = vector4(-350.09, -1570.02, 24.22, 297),
             materials = {
                 ['steel'] = { name = 'Scrap Metal', price = {min = 12, max = 18} },
                 ['copper'] = { name = 'Copper', price = {min = 12, max = 18} }
             }
         }
     }
     ```
   - Adjust the price ranges (`min` and `max`) or set static prices as needed.

3. **Key Features**:
   - Interactive UI using `ox_lib` for displaying shop options and player inventory.
   - Configurable shops with support for clean or dirty money transactions.
   - Framework agnostic: works seamlessly with ESX, QBCore, and QBOX.

## Installation

1. Download or clone this repository into your `resources` folder.
2. Add `ensure neon_sellshop` to your `server.cfg`.
3. Configure `config.lua` to match your server’s framework and shop requirements.
4. Restart your server or run `refresh` followed by `start neon_sellshop`.
