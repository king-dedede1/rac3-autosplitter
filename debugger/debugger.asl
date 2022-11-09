state("racman") {}

init 
{
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

    vars.GetTextComponentPointer = (Func<string, dynamic>)((name) => {
        foreach (dynamic component in timer.Layout.Components)
        {
            if (component.GetType().Name == "TextComponent" && component.Settings.Text1 == name) {
                return component;
            }
        }
        return null;
    });

    vars.dp_text = vars.GetTextComponentPointer("Destination Planet");
    vars.p_text = vars.GetTextComponentPointer("Planet");
    vars.ps_text = vars.GetTextComponentPointer("Player State");
    vars.pfc_text = vars.GetTextComponentPointer("Time on Planet");
    vars.gs_text = vars.GetTextComponentPointer("Game State");
    vars.ls_text = vars.GetTextComponentPointer("Loading Screen");
    vars.nh_text = vars.GetTextComponentPointer("Nefarious Health");
    vars.np_text = vars.GetTextComponentPointer("Nefarious Phase");
}

update
{
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

    var planetsList = new string[] {
            "Rac3Veldin",
            "Florana",
            "StarshipPhoenix",
            "Marcadia",
            "Daxx",
            "PhoenixRescue",
            "AnnihilationNation",
            "Aquatos",
            "Tyhrranosis",
            "ZeldrinStarport",
            "ObaniGemini",
            "BlackwaterCity",
            "Holostar",
            "Koros",
            "Unknown",
            "Rac3Metropolis",
            "CrashSite",
            "Rac3Aridia",
            "QwarksHideout",
            "LaunchSite",
            "ObaniDraco",
            "CommandCenter",
            "Holostar2",
            "InsomniacMuseum",
            "Unknown2",
            "MetropolisRangers",
            "AquatosClank",
            "AquatosSewers",
            "TyhrranosisRangers",
            "VidComic6",
            "VidComic1",
            "VidComic4",
            "VidComic2",
            "VidComic3",
            "VidComic5",
            "VidComic1SpecialEdition"
    };

    vars.dp_text.Settings.Text2 = current.destinationPlanet != 0  ? planetsList[current.destinationPlanet-1] : "(none)";
    vars.p_text.Settings.Text2 = current.planet != 0  ? planetsList[current.planet-1] : "(none)";
    vars.ps_text.Settings.Text2 = "0x"+current.playerState.ToString("X");
    vars.pfc_text.Settings.Text2 = TimeSpan.FromSeconds(current.planetFramesCount/60).ToString();
    vars.gs_text.Settings.Text2 = "0x"+current.gameState.ToString("X");
    vars.ls_text.Settings.Text2 = current.loadingScreen.ToString();
    vars.nh_text.Settings.Text2 = 100*current.neffyHealth+"%";
    vars.np_text.Settings.Text2 = "0x"+current.neffyPhase.ToString("X");
}