import json
import subprocess
import os
import sys

app_json_path = "/home/ubuntu/yn-build/package/app.json"
if not os.path.exists(app_json_path):
    app_json_path = "/home/ubuntu/y2k-build/package/app.json"

syscalls_cap = None
if os.path.exists(app_json_path):
    with open(app_json_path, "r", encoding="utf-8") as f:
        old_data = json.load(f)
    for cap in old_data.get("kernel_capabilities", []):
        if cap.get("type") == "syscalls":
            syscalls_cap = cap
            break

new_data = {
    "name": "Yume 2kki NX",
    "program_id": "0x0100B2B2C3D40000",
    "program_id_range_min": "0x0100B2B2C3D40000",
    "program_id_range_max": "0x0100B2B2C3D40000",
    "main_thread_stack_size": "0x100000",
    "main_thread_priority": 44,
    "default_cpu_id": 0,
    "process_category": 0,
    "system_resource_size": "0x0",
    "version": 0,
    "signature_key_generation": 0,
    "is_retail": True,
    "pool_partition": 0,
    "is_64_bit": True,
    "address_space_type": 1,
    "optimize_memory_allocation": False,
    "disable_device_address_space_merge": False,
    "enable_alias_region_extra_size": False,
    "prevent_code_reads": False,
    "filesystem_access": {
        "permissions": "0xFFFFFFFFFFFFFFFF"
    },
    "service_host": ["*"],
    "service_access": ["*"],
    "kernel_capabilities": [
        {
            "type": "kernel_flags",
            "value": {
                "highest_thread_priority": 59,
                "lowest_thread_priority": 28,
                "highest_cpu_id": 2,
                "lowest_cpu_id": 0
            }
        },
        {
            "type": "application_type",
            "value": 1
        },
        {
            "type": "min_kernel_version",
            "value": "0x30"
        },
        {
            "type": "handle_table_size",
            "value": 512
        },
        {
            "type": "debug_flags",
            "value": {
                "allow_debug": True,
                "force_debug": False,
                "force_debug_prod": False
            }
        }
    ]
}

if syscalls_cap:
    new_data["kernel_capabilities"].append(syscalls_cap)

out_json = sys.argv[1] if len(sys.argv) > 1 else "/home/ubuntu/y2k-build/tools/modern_app.json"
out_npdm = sys.argv[2] if len(sys.argv) > 2 else "/home/ubuntu/y2k-build/package/exefs/main.npdm"

os.makedirs(os.path.dirname(out_json), exist_ok=True)
os.makedirs(os.path.dirname(out_npdm), exist_ok=True)

with open(out_json, "w", encoding="utf-8") as f:
    json.dump(new_data, f, indent=2)

print(f"Saved {out_json}")

res = subprocess.run(
    ["/opt/devkitpro/tools/bin/npdmtool", out_json, out_npdm],
    capture_output=True,
    text=True
)
print("npdmtool returncode:", res.returncode)
print("npdmtool stdout:", res.stdout)
print("npdmtool stderr:", res.stderr)
