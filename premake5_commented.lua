

-- Setting up the workspace. A workspace can have multiple Projects. In visual studio a workspace corresponds to a solution.
workspace "HelloWorld"

  -- LUA note: 'workspace' is a function, that we are calling with an argument of "Hello World".
  --              The parentheses () for functions are optional in lua, but only when there is no ambiguity.
  --              
  --              For example if I was using an operator to modify the argument, like:
  --                   workspace "HelloWorld" + 2
  --              That would be ambiguous and cause an error, because it can represent either:
  --                   workspace("HelloWorld") + 2
  --              or
  --                   workspace("HelloWorld" + 2)
  --                   
  --              Similarly since tables/lists/arrays are writen with curly braces {}, you can
  --              pass that in without () as well, like with the 'configurations' function below.


  -- LUA note: indentation and whitespace is not important in lua. They are used here only to improve readability.

  -- defining debug and release configurations (see string token "%{cfg.buildcfg}")
  configurations { "Debug", "Release" }
  -- defining and release configurations (see string token "%{cfg.platform}")
  platforms { "x64", "x32" }


  local project_action = "UNDEFINED"
  -- LUA NOTE: by default all variables are global unless using local keyword.


  -- _ACTION is the argument passed into premake5 when you run it.
  if _ACTION ~= nill then
    project_action = _ACTION
  end
  -- LUA note: Quick example of if statement. 
  --           Since LUA does not require semicolons or care about whitespace, scopes are closed with 'end'
  --           when writing functions, if/while loops, etc.
  --           
  --           Also: ~ is negation LUA operator
  

  -- Where the project files (vs project, solution, etc) go
  location( "project_" .. project_action )
  -- LUA Note: string concatonation is performed with the concatonate .. operator. 
  --           So this:
  --              "Hello" .. "World"
  --           Results in:
  --              "HelloWorld"
  --              
  --           Notice how for the above 'location' function call we had to use parentheses, 
  --           since otherwise it would have been amgiguous.


  -- Setting up the actual project.
  project "HelloWorld"
    kind "ConsoleApp" -- "WindowApp" removes console
    language "C"
    targetdir "bin_%{cfg.buildcfg}_%{cfg.platform}" -- where the output binary goes. this will be generated when we build from the makefile/visual studio project/etc.



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
              --     this is super important if you have a filter that might otherwise
              --     affect function calls further down
           
  

    -- FILES AND LIBS --

    local SourceDir = "./Source/";
    -- what files the visual studio project/makefile/etc should know about
    files
    { 
      -- all paths in premake can have * for wildcard.
      --     /Some/Path/*.txt     will find any .txt file in /Some/Path
      --     /Some/Path/**.txt    will find any .txt file in /Some/Path and any of its subdirectories
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

    -- for template files
    -- filter { "files:**.tpp" }
    --   flags {"ExcludeFromBuild"}

    -- make sure to clear filter when done
    filter {}



    -- where to find header files that you might be including, mainly for library headers.
    includedirs
    {
      SourceDir -- include root source directory to allow for absolute include paths
      -- include the headers of any libraries/dlls you need
    }

    -- basically a set of paths/rules for where to find libs/dlls/etc
    libdirs
    {
      -- provide a path(s) for your libraries that are required when compiling.
      -- fmod, etc.
      -- example: 
      --     "./Source/Dependencies/fmod_version/lib"
      -- or to be more generic:
      --     "./Source/Dependencies/**/lib" which could be constructed from strings, like: 
      --     SourceDir .. "Dependencies/**/lib"
      --     
      -- NOTE: if you want to include debug/release specific libraries use tokens:
      --     %{cfg.buildcfg} evaluates to "Debug", "Release", etc.
      --     so if you structure your libraries to have a folder with "Debug" or "Release" 
      --     that contain the appropriate lib/dll/whatever then you can just do something like:
      --   SourceDir.."Dependencies/**/lib_%{cfg.buildcfg}" which will for example evaluate for:
      --   "/Source/Dependencies/fmod_01/lib_x32", which you would put the 32 bit version of fmod's lib into.
    }

    links
    {
      -- a list of the actual library/dll names to include
      -- for example if you want to include fmod_123.lib you put "fmod_123" here. Just like when adding to visual studio's linker.
    }

    -- note: for any of these you can call them inside of filters, for example:
    -- filter { "configurations:Debug" }
    --    links { "fmod_debug"}
    --  filter { "configurations:Release" }
    --    links { "fmod_release"}
    --    
    --    this goes for files, libdirs, really any directives.






