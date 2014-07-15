STRINGS = {
    "_DEMO_" => "true",
}

BUNDLES = {
    "MadMeshCombiner" => {
        :rootdir => "Assets/Mad Mesh Combiner",
        :output => "Assets/Mad Mesh Combiner/Scripts/MadMeshCombiner.dll",
        :files => "Assets/Mad Mesh Combiner/Scripts/*.cs",
        :defines => ["UNITY_4_3"],
        :guid => "988ab97878e8d5da65f527afbcaadc98",
        :update_references => true,
        :remove_sources => true,
    },

    "MadMeshCombiner_Editor" => {
        :rootdir => "Assets/Mad Mesh Combiner",
        :output => "Assets/Mad Mesh Combiner/Scripts/Editor/MadMeshCombiner_Editor.dll",
        :files => "Assets/Mad Mesh Combiner/Scripts/Editor/*.cs",
        :references => [:UnityEditor, "MadMeshCombiner"],
        :defines => ["UNITY_4_3"],
        :guid => "4c441234938084a6594256b1bd5ef5e9",
        :update_references => true,
        :remove_sources => true,
    }
}