import tkinter as tk
from tkinter import ttk
import pyautogui
import threading
import time
from datetime import datetime
import pystray
from PIL import Image
import random
import requests
import webbrowser
from packaging import version

class ActivitySimulator:
    VERSION = "1.0.0"
    
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Activity Simulator")
        
        # Use system theme
        try:
            self.root.tk.call('source', 'azure.tcl')
            self.root.tk.call('set_theme', 'light')
        except:
            pass  # Fall back to default theme if azure theme is not available
        
        self.is_running = False
        self.current_thread = None
        
        # Create and set up the GUI
        self.setup_gui()
        self.setup_tray_icon()
        self.check_for_updates()
        
    def setup_gui(self):
        # Activity type selection
        activity_frame = ttk.LabelFrame(self.root, text="Activity Type", padding=10)
        activity_frame.pack(fill="x", padx=10, pady=5)
        
        self.activity_var = tk.StringVar(value="mouse")
        ttk.Radiobutton(activity_frame, text="Mouse Wiggle", variable=self.activity_var, 
                       value="mouse").pack(anchor="w")
        ttk.Radiobutton(activity_frame, text="Keyboard Press", variable=self.activity_var, 
                       value="keyboard").pack(anchor="w")
        
        # Keyboard key selection
        key_frame = ttk.LabelFrame(self.root, text="Keyboard Key (for keyboard mode)", padding=10)
        key_frame.pack(fill="x", padx=10, pady=5)
        self.key_var = tk.StringVar(value="shift")
        ttk.Entry(key_frame, textvariable=self.key_var).pack(fill="x")
        
        # Interval selection
        interval_frame = ttk.LabelFrame(self.root, text="Interval (seconds)", padding=10)
        interval_frame.pack(fill="x", padx=10, pady=5)
        self.interval_var = tk.StringVar(value="300")
        ttk.Entry(interval_frame, textvariable=self.interval_var).pack(fill="x")
        
        # Add randomization options
        random_frame = ttk.LabelFrame(self.root, text="Randomization", padding=15)
        random_frame.pack(fill="x", pady=10)
        
        self.random_interval_var = tk.BooleanVar(value=False)
        ttk.Checkbutton(random_frame, text="Randomize interval (±30%)", 
                       variable=self.random_interval_var).pack(anchor="w")
        
        self.random_movement_var = tk.BooleanVar(value=False)
        ttk.Checkbutton(random_frame, text="Randomize mouse movement", 
                       variable=self.random_movement_var).pack(anchor="w")
        
        # Status display
        self.status_var = tk.StringVar(value="Status: Stopped")
        status_label = ttk.Label(self.root, textvariable=self.status_var)
        status_label.pack(pady=10)
        
        # Last action display
        self.last_action_var = tk.StringVar(value="Last action: Never")
        last_action_label = ttk.Label(self.root, textvariable=self.last_action_var)
        last_action_label.pack(pady=5)
        
        # Control buttons with better styling
        button_frame = ttk.Frame(self.root)
        button_frame.pack(pady=15)
        
        style = ttk.Style()
        style.configure('Start.TButton', background='green')
        style.configure('Stop.TButton', background='red')
        
        self.start_button = ttk.Button(button_frame, text="Start", 
                                     command=self.start_simulation,
                                     style='Start.TButton', width=15)
        self.start_button.pack(side="left", padx=5)
        
        self.stop_button = ttk.Button(button_frame, text="Stop", 
                                    command=self.stop_simulation,
                                    style='Stop.TButton', width=15)
        self.stop_button.pack(side="left", padx=5)
        self.stop_button.config(state="disabled")
        
        # Add preview button
        preview_button = ttk.Button(button_frame, text="Preview", 
                                  command=self.preview_action,
                                  width=15)
        preview_button.pack(side="left", padx=5)
    
    def simulate_activity(self):
        while self.is_running:
            try:
                if self.activity_var.get() == "mouse":
                    # Move mouse slightly right and then back
                    current_x, current_y = pyautogui.position()
                    pyautogui.moveRel(10, 0, duration=0.5)
                    pyautogui.moveRel(-10, 0, duration=0.5)
                else:
                    # Press and release the specified key
                    key = self.key_var.get()
                    pyautogui.press(key)
                
                current_time = datetime.now().strftime("%H:%M:%S")
                self.last_action_var.set(f"Last action: {current_time}")
                
                # Wait for the specified interval
                interval = float(self.interval_var.get())
                time.sleep(interval)
                
            except Exception as e:
                self.status_var.set(f"Error: {str(e)}")
                self.stop_simulation()
                break
    
    def start_simulation(self):
        try:
            # Validate interval
            interval = float(self.interval_var.get())
            if interval <= 0:
                raise ValueError("Interval must be positive")
            
            self.is_running = True
            self.status_var.set("Status: Running")
            self.start_button.config(state="disabled")
            self.stop_button.config(state="normal")
            
            # Start the simulation in a separate thread
            self.current_thread = threading.Thread(target=self.simulate_activity)
            self.current_thread.daemon = True
            self.current_thread.start()
            
        except ValueError as e:
            self.status_var.set(f"Error: {str(e)}")
    
    def stop_simulation(self):
        self.is_running = False
        self.status_var.set("Status: Stopped")
        self.start_button.config(state="normal")
        self.stop_button.config(state="disabled")
    
    def setup_tray_icon(self):
        # Create a simple icon (you can replace with your own .ico file)
        icon_image = Image.new('RGB', (64, 64), color='blue')
        menu = (
            pystray.MenuItem("Show", self.show_window),
            pystray.MenuItem("Start", self.start_simulation),
            pystray.MenuItem("Stop", self.stop_simulation),
            pystray.MenuItem("Exit", self.quit_app)
        )
        self.tray_icon = pystray.Icon(
            "ActivitySimulator",
            icon_image,
            "Activity Simulator",
            menu
        )
        
        # Add minimize button to window
        minimize_btn = ttk.Button(self.root, text="Hide to Tray", 
                                command=self.minimize_to_tray)
        minimize_btn.pack(pady=5)
    
    def minimize_to_tray(self):
        self.root.withdraw()  # Hide the window
        threading.Thread(target=self.tray_icon.run, daemon=True).start()
    
    def show_window(self, icon, item):
        self.tray_icon.stop()
        self.root.after(0, self.root.deiconify)
    
    def quit_app(self, icon, item):
        self.stop_simulation()
        self.tray_icon.stop()
        self.root.destroy()
    
    def preview_action(self):
        """Perform the selected action once without starting the timer"""
        if self.activity_var.get() == "mouse":
            current_x, current_y = pyautogui.position()
            pyautogui.moveRel(10, 0, duration=0.5)
            pyautogui.moveRel(-10, 0, duration=0.5)
        else:
            key = self.key_var.get()
            pyautogui.press(key)
    
    def get_random_interval(self, base_interval):
        if self.random_interval_var.get():
            variation = base_interval * 0.3  # 30% variation
            return random.uniform(base_interval - variation, base_interval + variation)
        return base_interval
    
    def get_random_movement(self):
        if self.random_movement_var.get():
            return random.randint(-20, 20), random.randint(-20, 20)
        return 10, 0
    
    def check_for_updates(self):
        try:
            # Replace with your actual update check URL
            response = requests.get("https://api.github.com/repos/yourusername/ActivitySimulator/releases/latest")
            latest_version = response.json()["tag_name"].strip("v")
            
            if version.parse(latest_version) > version.parse(self.VERSION):
                if tk.messagebox.askyesno(
                    "Update Available",
                    f"A new version ({latest_version}) is available. Would you like to download it?"
                ):
                    webbrowser.open(response.json()["html_url"])
        except:
            pass  # Silently fail if update check fails
    
    def run(self):
        self.root.protocol('WM_DELETE_WINDOW', self.minimize_to_tray)  # Handle window close button
        self.root.mainloop()

if __name__ == "__main__":
    # Create and run the application
    app = ActivitySimulator()
    app.run()