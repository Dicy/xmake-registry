package("chromium-embedded-framework")

    set_homepage("https://bitbucket.org/chromiumembedded")
    set_description("Chromium Embedded Framework (CEF). A simple framework for embedding Chromium-based browsers in other applications.")
    set_license("BSD-3-Clause")

    local buildver = {
        ["135.0.21"] = "135.0.21+gd008a99+chromium-135.0.7049.96"
    }
  
    if is_plat("windows") then
        add_urls("https://cef-builds.spotifycdn.com/cef_binary_$(version).tar.bz2", {version = function (version)
            return format("%s_windows%s", buildver[tostring(version)], (is_arch("x64") and "64" or "32"))
        end})
        if is_arch("x64") then
            add_versions("135.0.21", "af85614db3460aa497acf2124581ede227a013c00c62b61ccb2367644230e4e6")
        end
    elseif is_plat("macosx") then
        add_urls("https://cef-builds.spotifycdn.com/cef_binary_$(version).tar.bz2", {version = function (version)
            return format("%s_macos%s", buildver[tostring(version)], (is_arch("x64") and "x64" or "arm64"))
        end})
        if is_arch("arm64") then
            add_versions("135.0.21", "d8bb1f11882d1f50fd5c1b37a4ae8de070fa64f3cfea3993af7364bbb68ce1c1")
        end
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_plat("windows") then
        add_syslinks("user32", "advapi32", "shlwapi", "comctl32", "rpcrt4")
    end
    add_includedirs(".", "include")

    on_install("windows", function (package)
        local distrib_type = package:is_debug() and "Debug" or "Release"
        os.cp(path.join(distrib_type, "libcef.lib"), package:installdir("lib"))
        os.cp(path.join(distrib_type, "*.dll"), package:installdir("bin"))
        os.cp(path.join(distrib_type, "*.bin"), package:installdir("bin"))
        os.cp(path.join(distrib_type, "*.json"), package:installdir("bin"))
        os.cp("Resources/*", package:installdir("bin"))
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_install("macosx", function (package)
        local distrib_type = package:is_debug() and "Debug" or "Release"
        os.cp(path.join(distrib_type, "*"), package:installdir("bin"))
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("CefInitialize", {includes = "cef_app.h", configs = {languages = "c++17"}}))
    end)
