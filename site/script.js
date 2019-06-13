onload=() => {
    const video = document.querySelector("#stream")
    const player = new shaka.Player(video)
    player.configure({
            preferredAudioLanguage: "en",
            abr: {
              switchInterval: 1
            },
            streaming: {
              bufferingGoal: 2,
              alwaysStreamText: true
            }
    });
    player.load("source/stream/manifest.mpd").then(() => {
        window.player = player
    })
}

function setSubtitle(lang) {
    player.setTextTrackVisibility(true)
    player.selectTextLanguage(lang)
}

function hideSubtitle() {
    player.setTextTrackVisibility(false)
}

function SetSong(song) {
    player.selectAudioLanguage(song)
}
