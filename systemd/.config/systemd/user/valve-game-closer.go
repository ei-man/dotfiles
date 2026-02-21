//go:build ignore

package main

import (
	"log"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"syscall"
	"time"
)

var procToWindowTitle = map[string]string{
	"dota2": `"title": "Dota 2"`,
	"cs2":   `"title": "Counter-Strike 2"`,
}

var missCount = map[string]int{}

const missThreshold = 3

func main() {
	for {
		for proc, title := range procToWindowTitle {
			out, _ := exec.Command("pgrep", "-x", proc).Output()
			pid := strings.TrimSpace(string(out))
			if pid == "" {
				missCount[proc] = 0
				continue
			}

			out, _ = exec.Command("hyprctl", "clients", "-j").Output()
			if strings.Contains(string(out), title) {
				missCount[proc] = 0
				continue
			}

			missCount[proc]++
			if missCount[proc] >= missThreshold && age(pid) > 60 {
				log.Println("Killing orphaned", proc)
				p, _ := strconv.Atoi(pid)
				syscall.Kill(p, syscall.SIGKILL)
				missCount[proc] = 0
			}
		}
		time.Sleep(time.Second)
	}
}

func age(pid string) float64 {
	stat, _ := os.ReadFile("/proc/" + pid + "/stat")
	fields := strings.Fields(string(stat))
	if len(fields) < 22 {
		return 0
	}
	startTicks, _ := strconv.ParseFloat(fields[21], 64)
	uptime, _ := os.ReadFile("/proc/uptime")
	uptimeSec, _ := strconv.ParseFloat(strings.Fields(string(uptime))[0], 64)
	return uptimeSec - startTicks/100
}
