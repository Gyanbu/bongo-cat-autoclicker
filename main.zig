const std = @import("std");
const windows = std.os.windows;

extern "kernel32" fn GetModuleHandleA(lpModuleName: ?LPCSTR) callconv(.winapi) ?HMODULE;
extern "kernel32" fn GetProcAddress(hModule: HMODULE, lpProcName: LPCSTR) callconv(.winapi) ?FARPROC;
extern "kernel32" fn VirtualProtect(lpAddress: windows.LPVOID, dwSize: windows.SIZE_T, flNewProtect: windows.DWORD, lpflOldProtect: *windows.DWORD) callconv(.winapi) windows.BOOL;

const PAGE_READWRITE = 0x04;

const HWND = windows.HWND;
const HANDLE = windows.HANDLE;
const HMODULE = windows.HMODULE;
const LPCSTR = [*:0]const u8;
const FARPROC = *anyopaque;

export fn DllMain(
    hinstDLL: windows.HINSTANCE,
    fdwReason: windows.DWORD,
    lpvReserved: windows.LPVOID,
) callconv(.winapi) windows.BOOL {
    _ = hinstDLL;
    _ = lpvReserved;

    if (fdwReason != 1) return windows.TRUE;

    const user32 = GetModuleHandleA("user32.dll") orelse return windows.TRUE;
    const target_ptr = GetProcAddress(user32, "GetAsyncKeyState") orelse return windows.TRUE;

    var jmp = [_]u8{ 0x48, 0xB8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xE0 };
    const patch_addr = @intFromPtr(&patch);
    @memcpy(jmp[2..10], std.mem.asBytes(&patch_addr));

    var old_protect: windows.DWORD = 0;

    if (VirtualProtect(target_ptr, jmp.len, PAGE_READWRITE, &old_protect) == 0) return windows.TRUE;

    const target_slice = @as([*]u8, @ptrCast(target_ptr))[0..jmp.len];
    @memcpy(target_slice, &jmp);

    _ = VirtualProtect(target_ptr, jmp.len, old_protect, &old_protect);
    return windows.TRUE;
}

fn patch() align(16) callconv(.naked) void {
    asm volatile (
        \\ xorl %%eax, %%eax
        \\ cmpl $0x46, %%ecx
        \\ jne return
        \\ rdrand %%eax
        \\ andl $0x8000, %%eax
        \\ return:
        \\ retq
    );
}

pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    _ = msg;
    _ = error_return_trace;
    _ = ret_addr;
    @trap();
}
