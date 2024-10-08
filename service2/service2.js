import http from 'http';
import { execSync } from 'child_process';

const diskSpaceCmd = 'df | awk \'$6 == "/" {print $4}\'';
const processesCmd = "ps";
const uptimeCmd = "uptime | sed 's/^ [^ ]* up \\([^,]*,[^,]*\\),.*/\\1/'";
const ipCmd = "hostname -i";

function diskSpace() {
  return execSync(diskSpaceCmd).toString().trim();
}

function ip() {
  return execSync(ipCmd).toString().trim();
}

function uptime() {
  return execSync(uptimeCmd).toString().trim();
}

function processes() {
  const processTable = execSync(processesCmd).toString().trim();
  const procs =
    processTable.split('\n').slice(1).map((processStr) => {
      const infoList = processStr.split(/ +/i).slice(1);
      return {
        pid: infoList[0],
        user: infoList[1],
        time: infoList[2],
        command: infoList[3]
      };
    });
  return procs;
}

http.createServer(function(req, res) {
  const body = {
    ip: ip(),
    processes: processes(),
    diskSpace: diskSpace(),
    uptime: uptime()
  }

  res.writeHead(200, {'Content-Type': 'application/json'});
  res.write(JSON.stringify(body));
}).listen(8198)
