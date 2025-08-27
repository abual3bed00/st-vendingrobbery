# Vending Machine Robbery Script (QBCore)

# Author By "ii_abual3bed"
# Shadow Store discord ["https://discord.gg/7c2gZqD98A"]

## 📋 Overview
A script that allows players to rob vending machines in a QBCore server using electronic tools, featuring a complete system of challenges and risks.

---

## 🎯 Prerequisites

### Required Scripts:
1. **QBCore Framework** - Core framework
2. **qb-target** - Interaction system with objects
3. **st-mastermind** ["https://github.com/abual3bed00/st-mastermind"] - Minigame script for hacking
4. **cd_dispatch** - Police notification system (optional)

### Required Items:
- **Electronic Kit** - Electronic tool for hacking

---

## ⚙️ How It Works

### 1. Starting the Robbery
- Player interacts with a vending machine using **qb-target**
- "Rob Vending Machine" option appears
- Player must have an **Electronic Kit**

### 2. Hacking Process
- Progress bar for 5 seconds with animation
- Minigame using **st-mastermind**:
  - 6 attempts
  - 60 seconds time limit
- On success: receives rewards
- On failure: loses the attempt

### 3. Police Notification
- After 5 seconds from starting the robbery
- Notification sent to police department including:
  - Location of the incident
  - Player's gender
  - Blip for 5 minutes

---

## 🎁 Reward System

### Basic Rewards:
- **Gold Coins**: 1 to 3 pieces
- **Silver Coins**: 2 to 5 pieces

### Tool Risk System:
- After **3 uses** of the electronic tool
- **30% chance** for the tool to burn and be lost
- Counter resets after burning

---

## ⚠️ Security Features

### 1. Anti-Exploit:
- 5-minute cooldown per machine
- Entity control to prevent errors

### 2. Balanced System:
- Chance of losing tools
- Police notifications
- Minigame difficulty

### 3. Performance Tracking:
- Usage counter per player
- Data deletion when player disconnects

---

## 🔧 Setup and Installation

### Basic Steps:
1. Add the script to the resources folder
2. Adjust configuration as desired
3. Ensure required scripts are installed
4. Add items (Electronic Kit) to the database

### Customization:
- Modify rewards in `Config.Rewards`
- Change burn chance in `Config.ElectronicKit`
- Adjust cooldown time in the code

---

## 📊 Process Example

1. ➡️ Player finds a vending machine
2. 🎯 Interacts with it using QB-Target
3. 🔧 Uses Electronic Kit
4. ⏳ Waits 5 seconds with animation
5. 🎮 Plays hacking Minigame
6. ✅ On success: receives coins
7. 🚨 Police automatically notified
8. 🔥 Chance of tool burning after 3 uses

---

## 💡 Important Notes

- Script designed to be balanced and prevent exploitation
- Parameters can be adjusted according to server management preferences
- Integrates with core QBCore systems
- Supports police notifications and blips

This script adds interactive content for players with a complete system of rewards and risks!