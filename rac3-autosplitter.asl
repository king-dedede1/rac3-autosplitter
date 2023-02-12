// Skip to line 110 to edit the split route

state("racman") {

}

startup {
    settings.Add("USE_SPLIT_ROUTE", true, "Use split route");
    settings.SetToolTip("USE_SPLIT_ROUTE", "Use a split route.");
    settings.Add("STRICT_ORDER", false, "Strict order mode", "USE_SPLIT_ROUTE");
    settings.SetToolTip("STRICT_ORDER", "Require the splits in the path to be completed in order.");
    settings.Add("OLD_LONG_LOAD_REMOVAL", false, "Use old long load removal");
    settings.SetToolTip("OLD_LONG_LOAD_REMOVAL", "Use a different method to remove long loads.");
    settings.Add("BIO_SPLIT", true, "Split on biobliterator");
    settings.SetToolTip("BIO_SPLIT", "Splits on defeating the biobliterator, the final boss.");
    settings.Add("CATEGORY_NG+", false, "NG+", "USE_SPLIT_ROUTE");
    settings.SetToolTip("CATEGORY_NG+", "Preset split route for NG+. Use with the included blank splits.");
    settings.Add("CATEGORY_NG+_NO_QE", false, "NG+ No QE", "USE_SPLIT_ROUTE");
    settings.SetToolTip("CATEGORY_NG+_NO_QE", "Preset split route for NG+ no QE. Use with the included blank splits.");
    settings.Add("CATEGORY_ANY%", false, "Any%", "USE_SPLIT_ROUTE");
    settings.SetToolTip("CATEGORY_ANY%", "Preset split route for any%. Use with the included blank splits.");
    settings.Add("CATEGORY_ALL_TITANIUM_BOLTS", true, "All Titanium Bolts", "USE_SPLIT_ROUTE");
    settings.SetToolTip("CATEGORY_ALL_TITANIUM_BOLTS", "Preset split route for ATB. Use with the included blank splits.");
    settings.Add("CATEGORY_ALL_COLLECTABLES", false, "All Collectables", "USE_SPLIT_ROUTE");
    settings.SetToolTip("CATEGORY_ALL_COLLECTABLES", "Preset split route for All Collectables. Use with the included blank splits.");
    settings.Add("CATEGORY_100%", false, "100%", "USE_SPLIT_ROUTE");
    settings.SetToolTip("CATEGORY_100%", "Preset split route for 100% (with quit exploit). Use with the included blank splits.");
    settings.Add("CATEGORY_ALL_MISSIONS", false, "NG+ All Missions", "USE_SPLIT_ROUTE");
    settings.SetToolTip("CATEGORY_ALL_MISSIONS", "Preset split route for NG+ All Missions.");
    settings.Add("CATEGORY_ACT", false, "NG+ All Character Trophies", "USE_SPLIT_ROUTE");
    settings.SetToolTip("CATEGORY_ACT", "Preset split route for NG+ All Character Trophies.");
    settings.Add("CATEGORY_10TB", false, "10TB", "USE_SPLIT_ROUTE");
    settings.Add("CATEGORY_NG+ATB", false, "NG+ ATB", "USE_SPLIT_ROUTE");
    settings.Add("COUNT_LONG_LOADS", false, "Use long load counter");
    settings.SetToolTip("COUNT_LONG_LOADS", "Count the long loads in a text component. Requires a text component with the left text set to \"Long Loads\".");
    settings.Add("KOROS_BOLT_2", false, "Koros bolt 2 split", "CATEGORY_ALL_TITANIUM_BOLTS");
    settings.SetToolTip("KOROS_BOLT_2", "Split after getting both titanium bolts in Koros.\nThe courtney gears trophy is counted as a bolt");
}

init {
    System.IO.MemoryMappedFiles.MemoryMappedFile mmf = System.IO.MemoryMappedFiles.MemoryMappedFile.OpenExisting("racman-autosplitter");
    System.IO.MemoryMappedFiles.MemoryMappedViewStream stream = mmf.CreateViewStream();
    vars.reader = new System.IO.BinaryReader(stream);

    vars.reader.BaseStream.Position = 0;

    current.destinationPlanet = vars.reader.ReadByte();
    current.planet = vars.reader.ReadByte();
    current.playerState = vars.reader.ReadUInt16();
    current.planetFramesCount = vars.reader.ReadUInt32();
    current.gameState = vars.reader.ReadUInt32();
    current.loadingScreen = vars.reader.ReadByte();
    current.mission = vars.reader.ReadByte();
    current.neffyHealth = vars.reader.ReadSingle();
    current.neffyPhase = vars.reader.ReadUInt32();

    vars.shouldStopTimer = false;
    vars.SplitCount = 0;
    vars.biobliterator = false;

    vars.timer = new System.Windows.Forms.Timer();
    vars.timer.Enabled = false;

    vars.timer.Interval = 1000;
    vars.timer.Tick += new EventHandler((sender, e) => {
        vars.shouldStopTimer = false;
        vars.timer.Enabled = false;
    });

    vars.originPlanet = 0;
    vars.korosTBs = 0;
    vars.marcadiaTBs = 0;
    vars.longloads = 0;

    #region Level IDs

    byte Veldin = 1;
    byte Florana = 2;
    byte Phoenix = 3;
    byte Marcadia = 4;
    byte Daxx = 5;
    byte PhoenixRescue = 6;
    byte AnnihilationNation = 7;
    byte Aquatos = 8;
    byte Tyhrranosis = 9;
    byte ZeldrinStarport = 10;
    byte ObaniGemini = 11;
    byte BlackwaterCity = 12;
    byte HolostarRatchet = 13;
    byte Koros = 14;
    byte Level15cityname = 15;
    byte Metropolis = 16;
    byte CrashSite = 17;
    byte Aridia = 18;
    byte QwarksHideout = 19;
    byte LaunchSite = 20;
    byte ObaniDraco = 21;
    byte CommandCenter = 22;
    byte HolostarClank = 23;
    byte InsomniacMuseum = 24;
    byte Level25cityname = 25;
    byte MetropolisRangers = 26;
    byte AquatosClank = 27;
    byte AquatosSewers = 28;
    byte TyhrranosisRangers = 29;
    byte vc6 = 30;
    byte vc1 = 31;
    byte vc4 = 32;
    byte vc2 = 33;
    byte vc3 = 34;
    byte vc5 = 35;
    byte vc1special = 36;
    byte MainMenu = 255;

    #endregion

    // Ignore long loads when flying *to* these planets.
    vars.llIgnorePlanets = new byte[]{
        LaunchSite, MetropolisRangers, AquatosClank, AquatosSewers, TyhrranosisRangers
    }.ToList();

    // Ignore long loads when flying *from* these planets.
    vars.llIgnoreDestPlanets = new byte[]{
        LaunchSite, MetropolisRangers, AquatosClank, AquatosSewers, TyhrranosisRangers
    }.ToList();

    // Split Route for NG+
    vars.ngplus = new byte[]{
        Veldin, Florana,
        Florana, Phoenix,
        Phoenix, Marcadia,
        Marcadia, Phoenix,
        Phoenix, QwarksHideout,
        QwarksHideout, PhoenixRescue,
        PhoenixRescue, Koros,
        Koros, CommandCenter,
        CommandCenter, LaunchSite
    };

    // Split Route for NG+ No Quit Exploit
    vars.noqe = new byte[]{
        Veldin, Florana,
        Florana, Phoenix,
        Phoenix, Daxx,
        Daxx, ObaniGemini,
        ObaniGemini, BlackwaterCity,
        BlackwaterCity, Marcadia,
        Marcadia, Phoenix,
        AnnihilationNation, HolostarClank,
        HolostarRatchet, ObaniDraco,
        ObaniDraco, ZeldrinStarport,
        ZeldrinStarport, Phoenix,
        Metropolis, Phoenix,
        CrashSite, Phoenix,
        QwarksHideout, PhoenixRescue,
        PhoenixRescue, Koros,
        Koros, CommandCenter,
        CommandCenter, LaunchSite
    };

    // Split Route for any%
    vars.anypercent = new byte[]{
        Veldin, Florana,
        Florana, Phoenix,
        Marcadia, Phoenix,
        vc1, Phoenix,
        AnnihilationNation, Phoenix,
        Phoenix, Daxx,
        Daxx, ObaniGemini,
        ObaniGemini, BlackwaterCity,
        BlackwaterCity, AnnihilationNation,
        AnnihilationNation, HolostarClank,
        HolostarRatchet, ObaniDraco,
        ObaniDraco, ZeldrinStarport,
        ZeldrinStarport, Phoenix,
        vc2, Phoenix,
        vc3, Phoenix,
        vc4, Phoenix,
        Metropolis, Phoenix,
        CrashSite, Phoenix,
        vc5, Phoenix,
        QwarksHideout, PhoenixRescue,
        PhoenixRescue, Koros,
        Koros, CommandCenter,
        CommandCenter, LaunchSite 
    };

    // Split Route for All Titanium Bolts
    vars.atb = new byte[]{
        Veldin, Florana,
        Florana, Phoenix,
        Marcadia, Phoenix,
        vc1, Phoenix,
        AnnihilationNation, Phoenix,
        Phoenix, Daxx,
        Daxx, ObaniGemini,
        ObaniGemini, Aquatos,
        Aquatos, BlackwaterCity,
        BlackwaterCity, Phoenix,
        Tyhrranosis, AnnihilationNation,
        AnnihilationNation, HolostarClank,
        HolostarRatchet, ObaniDraco,
        ObaniDraco, ZeldrinStarport,
        ZeldrinStarport, Phoenix,
        vc2, Phoenix,
        vc3, Phoenix,
        vc4, Phoenix,
        Metropolis, Phoenix,
        CrashSite, Phoenix,
        vc5, Phoenix,
        Metropolis, Aridia,
        Phoenix, Aridia, // Level stack
        Aridia, QwarksHideout,
        QwarksHideout, PhoenixRescue,
        PhoenixRescue, Koros,
        Koros, CommandCenter,
        CommandCenter, LaunchSite
    };

    // Split Route for All Collectables
    vars.ac = new byte[]{
        Veldin, Florana,
        Florana, Phoenix,
        Marcadia, Phoenix,
        Phoenix, vc1,
        vc1, Phoenix,
        AnnihilationNation, Phoenix,
        Phoenix, Daxx,
        Daxx, ObaniGemini,
        ObaniGemini, Aquatos,
        Aquatos, BlackwaterCity,
        BlackwaterCity, Phoenix,
        Tyhrranosis, AnnihilationNation,
        AnnihilationNation, HolostarClank,
        HolostarRatchet, ObaniDraco,
        ObaniDraco, ZeldrinStarport,
        ZeldrinStarport, Phoenix,
        vc2, Phoenix,
        vc3, Phoenix,
        vc4, Phoenix,
        Metropolis, Florana,
        Florana, Phoenix,
        CrashSite, Phoenix,
        vc5, Phoenix,
        Metropolis, Aridia,
        Phoenix, QwarksHideout,
        QwarksHideout, PhoenixRescue,
        PhoenixRescue, Koros,
        Koros, Aridia,
        Aridia, Metropolis,
        Metropolis, Daxx,
        Daxx, Phoenix,
        Phoenix, CommandCenter,
        CommandCenter, LaunchSite
    };

    // Split Route for 100% (quit expoit route)
    vars.hundo = new byte[]{
        Veldin, Florana,
        Florana, Phoenix,
        Marcadia, Phoenix,
        vc1, Phoenix,
        AnnihilationNation, Phoenix,
        Phoenix, Daxx,
        Daxx, ObaniGemini,
        ObaniGemini, Aquatos,
        Aquatos, Phoenix,
        Florana, BlackwaterCity,
        BlackwaterCity, AnnihilationNation,
        AnnihilationNation, HolostarClank,
        HolostarRatchet, ObaniDraco,
        ObaniDraco, ZeldrinStarport,
        ZeldrinStarport, Phoenix,
        vc2, Phoenix,
        vc3, Phoenix,
        vc4, Phoenix,
        Metropolis, Phoenix,
        CrashSite, Phoenix,
        vc5, Phoenix,
        QwarksHideout, PhoenixRescue,
        Koros, Metropolis,
        Metropolis, QwarksHideout,
        QwarksHideout, CommandCenter,
        CommandCenter, Phoenix,
        Phoenix, Tyhrranosis,
        Tyhrranosis, Aridia,
        Aridia, Daxx,
        Daxx, CrashSite,
        CrashSite, AnnihilationNation,
        AnnihilationNation, CommandCenter,
        CommandCenter, LaunchSite
    };

    // Split route for NG+ All Story Missions.
    vars.allMissions = new byte[]{
        Veldin, Florana,
        Florana, Phoenix,
        Phoenix, Marcadia,
        Marcadia, Phoenix,
        AnnihilationNation, Phoenix,
        Aquatos, Phoenix,
        Tyhrranosis, Phoenix,
        Phoenix, Daxx,
        Daxx, ObaniGemini,
        ObaniGemini, BlackwaterCity,
        BlackwaterCity, AnnihilationNation,
        AnnihilationNation, HolostarClank,
        HolostarRatchet, ObaniDraco,
        ObaniDraco, ZeldrinStarport,
        ZeldrinStarport, Phoenix,
        Phoenix, Metropolis,
        Metropolis, Phoenix,
        CrashSite, Aridia,
        Aridia, Phoenix,
        Phoenix, QwarksHideout,
        QwarksHideout, PhoenixRescue,
        PhoenixRescue, Koros,
        Koros, CommandCenter,
        CommandCenter, LaunchSite
    };

    vars.tentb = new byte[]{
        Veldin, Florana,
        Florana, Phoenix,
        Phoenix, Daxx,
        Daxx, ObaniGemini,
        ObaniGemini, Marcadia
    };

    vars.act = new byte[]{
        Veldin, Florana,
        Florana, Phoenix,
        Phoenix, Marcadia,
        Marcadia, Phoenix,
        Phoenix, Daxx,
        Daxx, ObaniGemini,
        ObaniGemini, BlackwaterCity,
        BlackwaterCity, AnnihilationNation,
        AnnihilationNation, Phoenix,
        Aquatos, Phoenix,
        Tyhrranosis, HolostarClank,
        HolostarRatchet, ObaniDraco,
        ObaniDraco, ZeldrinStarport,
        ZeldrinStarport, Phoenix,
        Phoenix, Metropolis,
        Metropolis, Phoenix,
        CrashSite, Phoenix,
        Phoenix, QwarksHideout,
        QwarksHideout, PhoenixRescue,
        PhoenixRescue, Koros,
        Koros, CommandCenter,
        CommandCenter, LaunchSite
    };

    vars.ngplusatb = new byte[]{
        Veldin, Florana,
        Florana, Phoenix,
        Phoenix, Marcadia,
        Marcadia, Phoenix,
        Phoenix, vc1,
        vc1, Phoenix,
        Daxx, ObaniGemini,
        ObaniGemini, AnnihilationNation,
        AnnihilationNation, Phoenix,
        Aquatos, Phoenix,
        Tyhrranosis, BlackwaterCity,
        BlackwaterCity, HolostarClank,
        HolostarRatchet, ObaniDraco,
        ObaniDraco, ZeldrinStarport,
        ZeldrinStarport, Phoenix,
        vc2, Phoenix,
        vc3, Phoenix,
        vc4, Phoenix,
        Metropolis, Phoenix,
        CrashSite, Phoenix,
        vc5, Phoenix,
        Phoenix, Aridia,
        Aridia, QwarksHideout,
        QwarksHideout, PhoenixRescue,
        PhoenixRescue, Koros,
        Koros, CommandCenter,
        CommandCenter, LaunchSite
    };

    vars.LLCountText = null;

    vars.GetTextComponentPointer = (Func<string, dynamic>)((name) => {
        foreach (dynamic component in timer.Layout.Components)
        {
            if (component.GetType().Name == "TextComponent" && component.Settings.Text1 == name) {
                return component;
            }
        }
        return null;
    });
    
}

update {

    if (settings["COUNT_LONG_LOADS"] && vars.LLCountText == null) {
        vars.LLCountText = vars.GetTextComponentPointer("Long Loads");
    }

    if (settings["CATEGORY_NG+"]) {
        vars.SplitRoute = vars.ngplus;
    }
    else if (settings["CATEGORY_NG+_NO_QE"]) {
        vars.SplitRoute = vars.noqe;
    }
    else if (settings["CATEGORY_ANY%"]) {
        vars.SplitRoute = vars.anypercent;
    }
    else if (settings["CATEGORY_ALL_TITANIUM_BOLTS"]) {
        vars.SplitRoute = vars.atb;
    }
    else if (settings["CATEGORY_ALL_COLLECTABLES"]) {
        vars.SplitRoute = vars.ac;
    }
    else if (settings["CATEGORY_100%"]) {
        vars.SplitRoute = vars.hundo;
    }
    else if (settings["CATEGORY_ALL_MISSIONS"]) {
        vars.SplitRoute = vars.allMissions;
    }
    else if (settings["CATEGORY_10TB"]) {
        vars.SplitRoute = vars.tentb;
    }
    else if (settings["CATEGORY_ACT"]) {
        vars.SplitRoute = vars.act;
    }
    else if (settings["CATEGORY_NG+ATB"]) {
        vars.SplitRoute = vars.ngplusatb;
    }
    else {
        vars.SplitRoute = null;
    }

    vars.reader.BaseStream.Position = 0;
    current.destinationPlanet = vars.reader.ReadByte();
    current.planet = vars.reader.ReadByte();
    current.playerState = vars.reader.ReadUInt16();
    current.planetFramesCount = vars.reader.ReadUInt32();
    current.gameState = vars.reader.ReadUInt32();
    current.loadingScreen = vars.reader.ReadByte();
    current.mission = vars.reader.ReadByte();
    current.neffyHealth = vars.reader.ReadSingle();
    current.neffyPhase = vars.reader.ReadUInt32();

    if (current.planet != old.planet && current.destinationPlanet != 0) {
        vars.originPlanet = old.planet;
    }
    else if (current.planet == old.planet && current.destinationPlanet == 0) {
        vars.originPlanet = current.planet;
    }

    if (current.loadingScreen == 1 && old.loadingScreen != 1 && !vars.shouldStopTimer
    && !vars.llIgnorePlanets.Contains(vars.originPlanet)
    && !vars.llIgnoreDestPlanets.Contains(current.destinationPlanet)) {
        // Count a long load
        vars.longloads++;
        if (settings["OLD_LONG_LOAD_REMOVAL"]) {
            vars.timer.Enabled = true;
            vars.shouldStopTimer = true;
        }
        else {
            timer.SetGameTime(timer.CurrentTime.GameTime.Value.Subtract(TimeSpan.FromSeconds(1)));
        }     
    }

    if (settings["COUNT_LONG_LOADS"]) {
        if (vars.LLCountText != null) {
            vars.LLCountText.Settings.Text2 = vars.longloads.ToString();
        }
        else  {
            if (settings["DEBUG"]) print("LLCount is null");
        }
    }

    if (!vars.biobliterator && current.gameState == 0 && current.planet == 20 && current.neffyPhase % 2 == 1 && current.neffyHealth == 1) {
        vars.biobliterator = true;
        if (settings["DEBUG"]) print("Toggled biobliterator");
    }

    if (current.playerState == 0x74 && old.playerState != 0x74 && current.planet == 14) {
        vars.korosTBs++;
    }

    if (current.playerState == 0x74 && old.playerState != 0x74 && current.planet == 4) {
        vars.marcadiaTBs++;
    }

}

start {
    if (current.planet == 1 && // We are on veldin
    old.gameState == 6 &&      // The game was loading in the last frame
    current.gameState == 0){   // The game is in gameplay this frame
        vars.SplitCount = 0;
        vars.longloads = 0;
        vars.korosTBs = 0;
        vars.marcadiaTBs = 0;
        vars.biobliterator = false;
        return true;
    } 
}

split {
    if (current.neffyHealth == 0 && vars.biobliterator && current.planet == 20 && settings["BIO_SPLIT"]) {
        if (settings["DEBUG"]) print("Splitting on biobliterator");
        vars.biobliterator = false;
        vars.SplitCount++;
        return true;
    }
    else if (current.destinationPlanet != old.destinationPlanet && (current.planet != current.destinationPlanet) && current.destinationPlanet != 0 && current.planet != 0) {
        // we are changing levels (but not reloading, and not going to or from veldin)
        if (settings["STRICT_ORDER"]) {
            if (vars.SplitRoute[vars.SplitCount*2] == current.planet && vars.SplitRoute[vars.SplitCount*2+1] == current.destinationPlanet) {
                vars.SplitCount++;
                return true;
            }
        }
        else if (settings["USE_SPLIT_ROUTE"]) {
            for (int i = 0; i < vars.SplitRoute.Length; i += 2) {
                if (vars.SplitRoute[i] == current.planet && vars.SplitRoute[i+1] == current.destinationPlanet) {
                    vars.SplitCount++;
                    return true;
                }
            }
        }
        else {
            vars.SplitCount++;
            return true;
        }
    }
    else if (current.planet == 14 && vars.korosTBs >= 2 && settings["KOROS_BOLT_2"]) {
        vars.korosTBs = 0;
        return true;
    }
    else if (current.planet == 4 && vars.marcadiaTBs >= 2 && settings["CATEGORY_10TB"]) {
        vars.marcadiaTBs = 0;
        // return true;
    }
}

reset {
    if (current.planet == 1 && // We are on veldin
    old.gameState == 6 &&      // The game was loading in the last frame
    current.gameState == 0){   // The game is in gameplay this frame
        vars.SplitCount = 0;
        return true;
    } 
}

isLoading {
    return vars.shouldStopTimer;
}
