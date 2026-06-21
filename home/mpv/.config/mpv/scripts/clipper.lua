-- clipper.lua — mpv script to clip video under 10MiB
-- Keybinds:
--   c       : mark start
--   v       : mark end
--   Ctrl+c  : run ffmpeg (encode clip under 10MiB, x264 2-pass)

local utils = require("mp.utils")

local start_time = nil
local end_time = nil
local clip_counter = 1

local TARGET_SIZE_KB = 9.5 * 1024 -- ~9.5 MiB to account for container overhead
local AUDIO_BITRATE = 128         -- kbps

function format_time(seconds)
    if not seconds then return "-" end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%06.3f", h, m, s)
end

function mark_start()
    start_time = mp.get_property_number("time-pos")
    mp.osd_message("Start: " .. format_time(start_time), 3)
end

function mark_end()
    end_time = mp.get_property_number("time-pos")
    mp.osd_message("End: " .. format_time(end_time), 3)
end

function run_clipper()
    if not start_time or not end_time then
        mp.osd_message("Mark both start (c) and end (v) first!", 3)
        return
    end

    if end_time <= start_time then
        mp.osd_message("End must be after start!", 3)
        return
    end

    local input_path = mp.get_property("path")
    if not input_path then
        mp.osd_message("No file loaded", 3)
        return
    end

    -- Probe audio track count
    local probe = mp.command_native({
        name = "subprocess",
        args = {
            "ffprobe", "-v", "error",
            "-select_streams", "a",
            "-show_entries", "stream=index",
            "-of", "csv=p=0",
            input_path
        },
        capture_stdout = true,
        capture_stderr = true,
    })

    local audio_count = 0
    if probe.status == 0 and probe.stdout then
        for _ in probe.stdout:gmatch("[^\n]+") do
            audio_count = audio_count + 1
        end
    end

    -- Build output path in same directory
    local dir, filename = utils.split_path(input_path)
    local name_no_ext = filename:match("(.+)%..+$") or filename
    local outfile = utils.join_path(dir, name_no_ext .. "_clip" .. clip_counter .. ".mp4")
    local passlog = utils.join_path(dir, name_no_ext .. "_clip" .. clip_counter .. "_2pass")
    clip_counter = clip_counter + 1

    local duration = end_time - start_time
    local target_bitrate = math.floor((TARGET_SIZE_KB * 8) / duration) - AUDIO_BITRATE
    if target_bitrate < 100 then target_bitrate = 100 end

    mp.osd_message(
    "Encoding clip... (" ..
    string.format("%.1f", duration) .. "s, " .. audio_count .. " audio tracks @ " .. target_bitrate .. "k)", 5)

    local pass1 = {
        "ffmpeg", "-nostdin", "-y",
        "-ss", format_time(start_time),
        "-to", format_time(end_time),
        "-i", input_path,
        "-vf", "fps=30",
        "-c:v", "libx264",
        "-b:v", target_bitrate .. "k",
        "-preset", "medium",
        "-passlogfile", passlog,
        "-pass", "1",
        "-an",
        "-f", "null", "/dev/null"
    }

    -- Build pass2 args dynamically based on audio track count
    -- Video must be the first output stream (index 0) to match the pass 1 log file
    local pass2 = {
        "ffmpeg", "-nostdin", "-y",
        "-ss", format_time(start_time),
        "-to", format_time(end_time),
        "-i", input_path,
        "-map", "0:v:0",
        "-vf", "fps=30",
        "-c:v", "libx264",
        "-b:v", target_bitrate .. "k",
        "-preset", "medium",
        "-passlogfile", passlog,
        "-pass", "2",
    }

    if audio_count > 1 then
        table.insert(pass2, "-filter_complex")
        table.insert(pass2, "amix=inputs=" .. audio_count .. ":duration=longest:normalize=0[aout]")
        table.insert(pass2, "-map")
        table.insert(pass2, "[aout]")
    else
        table.insert(pass2, "-map")
        table.insert(pass2, "0:a:0")
    end

    table.insert(pass2, "-c:a")
    table.insert(pass2, "aac")
    table.insert(pass2, "-b:a")
    table.insert(pass2, AUDIO_BITRATE .. "k")
    table.insert(pass2, "-movflags")
    table.insert(pass2, "+faststart")
    table.insert(pass2, outfile)

    -- Run async so mpv doesn't freeze
    mp.command_native_async({
        name = "subprocess",
        args = pass1,
    }, function(success, result)
        if result.status ~= 0 then
            mp.osd_message("Pass 1 failed!", 5)
            return
        end
        mp.command_native_async({
            name = "subprocess",
            args = pass2,
        }, function(success2, result2)
            -- Clean up passlog files
            os.remove(passlog .. "-0.log")
            os.remove(passlog .. "-0.log.mbtree")

            if result2.status == 0 then
                mp.osd_message("Saved: " .. outfile, 5)
                mp.command("quit")
            else
                mp.osd_message("Pass 2 failed!", 5)
            end
        end)
    end)
end

mp.add_key_binding("c", "clipper-mark-start", mark_start)
mp.add_key_binding("v", "clipper-mark-end", mark_end)
mp.add_key_binding("Ctrl+c", "clipper-run", run_clipper)
