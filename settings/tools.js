var make_system_action = function(name) {
    return function() {
        var subprocess = require("subprocess");
        subprocess.check_call("sailfish_tools_system_action", [name]);
    };
};

exports.restartAlien = make_system_action("restart_dalvik");
exports.stopAlien = make_system_action("stop_dalvik");
