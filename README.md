I'm trying to follow this video but in Godot 3: https://youtu.be/VSwVwIYEypY
I'm having trouble with getting the basic collision detection wave to propagate
with the shader, which is somewhere from 0:00 to 6:50 in the video.

i have two shaders, one is attached to the material of the ColorRect
(you can follow the video on more details of what it does,
but it basically tries to simulate the water flow from moving objects
by looking at the surrounding pixels and changing the color based on the
previous state of collision), this one is in `shaders/simulation.shader`

And I rewrote the visual shader in the video into a normal one,
it's attached to the Water plane: `shaders/render.shader`

The workflow is something like this:
1. The collision viewport sees an object in the water (fully in red channel)
2. The simulation viewport's texture registers this collision and 
propagates this "wave" beyond the collided pixels, saving old collision
data and previous state into different colour channels
3. The water plane reads the sim viewport's texture and renders it

Sadly, when I run the game, no collision is visible and I have no idea
where to start with debugging these shaders.

If you preview of the collision camera, it does register the
collision of the ball in the middle of the animation.


