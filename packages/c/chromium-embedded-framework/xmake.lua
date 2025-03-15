package("chromium-embedded-framework")

    set_homepage("https://bitbucket.org/chromiumembedded")
    set_description("Chromium Embedded Framework (CEF). A simple framework for embedding Chromium-based browsers in other applications.")
    set_license("BSD-3-Clause")

    local buildver = {
        ["131.3.4"] = "131.3.4+g7ecebf0+chromium-131.0.6778.140"
    }
  
    if is_plat("windows") then
        add_urls("https://cef-builds.spotifycdn.com/cef_binary_$(version).tar.bz2", {version = function (version)
            return format("%s_windows%s", buildver[tostring(version)], (is_arch("x64") and "64" or "32"))
        end})
        if is_arch("x64") then
            -- TODO
        end
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MT", type = "string", readonly = true})
    elseif is_plat("macos") then
        add_urls("https://cef-builds.spotifycdn.com/cef_binary_$(version).tar.bz2", {version = function (version)
            return format("%s_macos%s", buildver[tostring(version)], (is_arch("x64") and "x64" or "arm64"))
        end})
        if is_arch("arm64") then
            add_versions("131.3.4", "c16329ff3beff7ab383d93fe5785eafe83dc3c0b34992cf28c59b0aa3f6fc7ec")
        end
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    
    if is_plat("windows") then
        add_syslinks("user32", "advapi32", "shlwapi", "comctl32", "rpcrt4")
    end
    add_includedirs(".", "include")

    on_install("windows", function (package)
        local distrib_type = package:debug() and "Debug" or "Release"
        os.cp(path.join(distrib_type, "*.lib"), package:installdir("lib"))
        os.cp(path.join(distrib_type, "*.dll"), package:installdir("bin"))
        os.cp(path.join(distrib_type, "swiftshader", "*.dll"), package:installdir("bin", "swiftshader"))
        os.cp(path.join(distrib_type, "*.bin"), package:installdir("bin"))
        os.cp("Resources/*", package:installdir("bin"))
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_install("macos", function (package)
        local distrib_type = package:debug() and "Debug" or "Release"
        os.cp(path.join(distrib_type, "*.lib"), package:installdir("lib"))
        os.cp(path.join(distrib_type, "*.dll"), package:installdir("bin"))
        os.cp(path.join(distrib_type, "swiftshader", "*.dll"), package:installdir("bin", "swiftshader"))
        os.cp(path.join(distrib_type, "*.bin"), package:installdir("bin"))
        os.cp("Resources/*", package:installdir("bin"))
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("CefEnableHighDPISupport", {includes = "cef_app.h"}))
    end)
