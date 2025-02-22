# Automatic Time Synchronization on Windows 10 Startup

If your Windows 10 system does not retain the correct time due to a hardware issue, you can configure it to automatically synchronize with an internet time server at startup. This guide provides two methods to achieve this.

---

## **Method 1: Using Task Scheduler**
This method creates a scheduled task that forces time synchronization at startup.

### **Steps:**
1. **Open Task Scheduler**:
   - Press `Win + R`, type `taskschd.msc`, and press **Enter**.

2. **Create a New Task**:
   - In the right pane, click **Create Task** (not "Create Basic Task").

3. **General Tab**:
   - Name the task (e.g., `TimeSyncStartup`).
   - Check **Run with highest privileges**.
   - Set **Configure for** to **Windows 10**.

4. **Triggers Tab**:
   - Click **New**.
   - Set **Begin the task** to **At startup**.
   - Check **Delay task for** and set it to `30 seconds`.
   - Click **OK**.

5. **Actions Tab**:
   - Click **New**.
   - Set **Action** to **Start a program**.
   - In the "Program/script" field, enter:
     ```
     w32tm
     ```
   - In the "Add arguments" field, enter:
     ```
     /resync
     ```
   - Click **OK**.

6. **Conditions Tab**:
   - Uncheck **Start the task only if the computer is on AC power** (optional).

7. **Settings Tab**:
   - Check **Allow task to be run on demand**.
   - Check **If the task fails, restart every** and set it to `1 minute`, with attempts **up to 10 times**.

8. **Save the Task**:
   - Click **OK** to finish creating the task.

---

## **Method 3: Modifying the Windows Registry**
This method forces Windows to synchronize time at a specified interval.

### **Steps:**
1. **Open Registry Editor**:
   - Press `Win + R`, type `regedit`, and press **Enter**.

2. **Navigate to the Time Service Settings**:
   - Go to:
     ```
     HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient
     ```

3. **Modify the SpecialPollInterval Value**:
   - Find **SpecialPollInterval** (DWORD value).
   - Double-click it to edit.
   - Select **Base: Decimal**.
   - Set the value to the desired synchronization interval in seconds:
     - `10` for every 10 seconds.
     - `60` for every 1 minute (recommended for testing).
     - `3600` for every 1 hour (default for many systems).
   - Click **OK**.

4. **Restart Windows Time Service**:
   - Press `Win + R`, type `services.msc`, and press **Enter**.
   - Find **Windows Time**, double-click it, and ensure:
     - **Startup type** is set to **Automatic**.
     - Click **Start** if the service is not running.
   - Click **OK**.

---

## **Final Notes**
- **Method 1** ensures time is synced at startup.
- **Method 3** allows frequent synchronization intervals.
- For best results, you can use **both methods together** to maintain accurate time automatically.

By following these steps, your Windows 10 system will always have the correct time, even if your motherboard cannot retain it.

