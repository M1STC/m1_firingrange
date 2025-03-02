window.addEventListener('message', function(event) {
    if (event.data.action === "openMenu") {
        document.body.style.display = "block"; 
    }
    if (event.data.action === "closeMenu") {
        document.body.style.display = "none"; 
    }
});


function startFiringRange() {
    fetch(`https://${GetParentResourceName()}/startFiringRange`, {
        method: 'POST',
    }).then(() => {
        document.body.style.display = "none";
    });
}


function stopFiringRange() {
    fetch(`https://${GetParentResourceName()}/stopFiringRange`, {
        method: 'POST',
    }).then(() => {
        document.body.style.display = "none"; 
    });
}

function closeMenu() {
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
    }).then(() => {
        document.body.style.display = "none"; 
    });
}


window.addEventListener('message', function(event) {
    if (event.data.action === "updateLeaderboard") {
        console.log("[DEBUG] Received Leaderboard Data:", event.data.leaderboard);
        
        const leaderboardList = document.getElementById('leaderboard-list');
        leaderboardList.innerHTML = '';

   
        if (Array.isArray(event.data.leaderboard) && event.data.leaderboard.length > 0) {
            event.data.leaderboard.forEach((entry, index) => {
                console.log(`[DEBUG] Rendering Leaderboard Entry: ${entry.name} - ${entry.score} pts`); 
                const listItem = document.createElement('li');
                listItem.textContent = `${index + 1}. ${entry.name} - ${entry.score} pts`;
                leaderboardList.appendChild(listItem);
            });
        } else {
            console.log("[DEBUG] No Leaderboard Data Found."); 
            leaderboardList.innerHTML = '<li>No scores yet!</li>';
        }
    }
});

