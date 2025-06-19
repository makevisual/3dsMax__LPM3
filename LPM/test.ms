rollout keyRollout "Key Listener"
(
    local altPressed = false -- Track if ALT is held down

    on keyRollout open do
    (
        --registerKeyEvents keyRollout
    )

    on keyRollout keyDown arg do
    (
        if arg.name == "alt" then
        (
            altPressed = true -- Mark ALT as held down
        )
        if altPressed then
        (
            if arg.name == "up" then
            (
                print "ALT + UP Arrow Pressed!"
                -- Trigger your event here
            )
            if arg.name == "down" then
            (
                print "ALT + DOWN Arrow Pressed!"
                -- Trigger your event here
            )
        )
    )

    on keyRollout keyUp arg do
    (
        if arg.name == "alt" then
        (
            altPressed = false -- Reset ALT key tracking when released
        )
    )
)

clearListener()
createDialog keyRollout
