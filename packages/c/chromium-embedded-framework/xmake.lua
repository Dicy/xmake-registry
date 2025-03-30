package("chromium-embedded-framework")

    set_homepage("https://bitbucket.org/chromiumembedded")
    set_description("Chromium Embedded Framework (CEF). A simple framework for embedding Chromium-based browsers in other applications.")
    set_license("BSD-3-Clause")

    local buildver = {
        ["134.3.2"] = "134.3.2+g615db2f+chromium-134.0.6998.89"
    }
  
    if is_plat("windows") then
        add_urls("https://cef-builds.spotifycdn.com/cef_binary_$(version).tar.bz2", {version = function (version)
            return format("%s_windows%s", buildver[tostring(version)], (is_arch("x64") and "64" or "32"))
        end})
        if is_arch("x64") then
            add_versions("134.3.2", "856cccd8f8b7ebd4cabad7a7ce1bd7596c18bba641bb0f2eae4d3ee51b3c7265")
        end
        add_configs("runtime", {description = "Set vs compiler runtime.", default = "MT", type = "string", readonly = true})
    elseif is_plat("macosx") then
        add_urls("https://cef-builds.spotifycdn.com/cef_binary_$(version).tar.bz2", {version = function (version)
            return format("%s_macos%s", buildver[tostring(version)], (is_arch("x64") and "x64" or "arm64"))
        end})
        if is_arch("arm64") then
            add_versions("134.3.2", "dd6551579493ee203d70ddaccc243c87cd5151f956e49203925992adfd3c3dcd")
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
        os.cp(path.join(distrib_type, "*.bin"), package:installdir("bin"))
        os.cp("Resources/*", package:installdir("bin"))
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_install("macosx", function (package)
        local distrib_type = package:debug() and "Debug" or "Release"
        os.cp(distrib_type, package:installdir("bin"))
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("CefInitialize", {includes = "cef_app.h", configs = {languages = "c++17"}}))
    end)
