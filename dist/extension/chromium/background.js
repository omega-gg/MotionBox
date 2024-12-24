chrome.action.onClicked.addListener((tab) =>
{
    if (tab == null || tab.url == "") return;

    try
    {
        chrome.scripting.executeScript(
        {
            target: { tabId: tab.id },
            func: () =>
            {
                if (location.hostname.includes('youtube.com'))
                {
                    // NOTE: Use YouTube's player API to pause the video.
                    const player = document.querySelector('#movie_player');

                    if (player && typeof player.pauseVideo === 'function')
                    {
                        player.pauseVideo();

                        return;
                    }
                }

                // NOTE: For non-YouTube sites, pause all video and audio elements.
                const mediaElements = document.querySelectorAll('video, audio');

                mediaElements.forEach(media => { media.pause(); });
            }
        }, () =>
        {
            // NOTE: After stopping media, construct the vbml URI.
            const currentUrl = new URL(tab.url);

            const vbmlUri = `vbml://${currentUrl.href.replace(/^https?:\/\//, '')}`;

            // NOTE: Open the VBML uri.
            chrome.tabs.update(tab.id, { url: vbmlUri }, () =>
            {
                console.log(`Opened VBML uri: ${vbmlUri}`);
            });
        });
    }
    catch (error)
    {
        console.error("Failed to execute action:", error);
    }
});
