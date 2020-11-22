prefix ap. # animation player

signals
    frame

    left
    right
    up
    down

    lowkick
    lowpunch
    hikick
    hipunch

    hit
end

states
    Idle 10
    Block 2
    Punch 4
    Kick 5
    Uppercut 6

    Crouch 1
    LowBlock 2
    LowKick 5
    LowPunch 2
end

gen loop on frame Idle
gen loop on frame Block
gen loop on frame LowBlock
gen fwd on frame Punch

edges
    Idle left Left
    Idle right Right
    Idle up Jump
    Idle down Crouch

    Idle hikick Kick
    Idle hipunch Punch
    Idle hiuppercut Uppercut

    Idle down Crouch
    Crouch kick LowKick
end
