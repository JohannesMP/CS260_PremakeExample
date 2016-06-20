

-- Setting up the workspace.
workspace "HelloWorld"
  -- defining debug and release configurations (see string token "%{cfg.buildcfg}")
  configurations { "Debug", "Release" }
  -- defining and release configurations (see string token "%{cfg.platform}")
  platforms { "x64", "x32" }

  local project_action = "UNDEFINED"

  -- _ACTION is the argument passed into premake5 when you run it.
  if _ACTION ~= nill then
    project_action = _ACTION
  end

  -- Where the project files (vs project, solution, etc) go
  location( "project_" .. project_action )

  -- Setting up the actual project.
  project "HelloWorld"
    kind "ConsoleApp" -- "WindowApp" removes console
    language "C"
    targetdir "bin_%{cfg.buildcfg}_%{cfg.platform}" -- where the output binary goes.


    -- COMPILING/LINKING --

    -- flags { "FatalWarnings" } -- uncomment if you want warnings to count as errors
    warnings "Extra"

    -- see 'filter' in the wiki pages
    filter "configurations:Debug"    defines { "DEBUG" }  flags { "Symbols" }
    filter "configurations:Release"  defines { "NDEBUG" } optimize "On"

    filter { "platforms:*32" } architecture "x86"
    filter { "platforms:*64" } architecture "x64"

    -- when building any visual studio project
    filter { "system:windows", "action:vs*"}
      flags         { "MultiProcessorCompile", "NoMinimalRebuild" }
      linkoptions   { "/ignore:4099" }      -- Ignore library pdb warnings when running in debug


    filter {} -- clear filter when you know you no longer need it!


    -- FILES AND LIBS --

    local SourceDir = "./Source/";
    -- what files the visual studio project/makefile/etc should know about
    files
    { 
      SourceDir .. "**.h", 
      SourceDir .. "**.c",
      SourceDir .. "**.hpp", 
      SourceDir .. "**.cpp",
      SourceDir .. "**.tpp"
    }

    -- Exclude template files from project (so they don't accidentally get compiled)
    filter { "files:**.tpp" }
      flags {"ExcludeFromBuild"}


    -- setting up visual studio filters (basically virtual folders).
    vpaths 
    {
      ["Header Files/*"] = { SourceDir .. "**.h", SourceDir .. "**.hxx", SourceDir .. "**.hpp" },
      ["Source Files/*"] = { SourceDir .. "**.c", SourceDir .. "**.cxx", SourceDir .. "**.cpp" },
    }

    -- make sure to clear filter when done
    filter {}




    -- where to find header files that you might be including, mainly for library headers.
    includedirs
    {
      SourceDir -- include root source directory to allow for absolute include paths
      -- include the headers of any libraries/dlls you need
    }

    libdirs
    {
      -- add dependency directories here
    }

    links
    {
      -- add depedencies (libraries) here
    }




