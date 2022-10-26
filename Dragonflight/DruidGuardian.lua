-- DruidGuardian.lua
-- October 2022

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 104 )

spec:RegisterResource( Enum.PowerType.Rage, {
    oakhearts_puny_quods = {
        aura = "oakhearts_puny_quods",

        last = function ()
            local app = state.buff.oakhearts_puny_quods.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 10
    },

    raging_frenzy = {
        aura = "frenzied_regeneration",
        pvptalent = "raging_frenzy",

        last = function ()
            local app = state.buff.frenzied_regeneration.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 10 -- tooltip says 60, meaning this would be 20, but NOPE.
    },

    thrash_bear = {
        aura = "thrash_bear",
        talent = "blood_frenzy",
        debuff = true,

        last = function ()
            return state.debuff.thrash_bear.applied + floor( ( state.query_time - state.debuff.thrash_bear.applied ) / class.auras.thrash_bear.tick_time ) * class.auras.thrash_bear.tick_time
        end,

        interval = function () return class.auras.thrash_bear.tick_time end,
        value = function () return 2 * state.active_dot.thrash_bear end,
    }
} )
spec:RegisterResource( Enum.PowerType.LunarPower )
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

-- Talents
spec:RegisterTalents( {
    after_the_wildfire            = { 82140, 371905, 1 }, -- TODO: Every 200 Rage you spend causes a burst of restorative energy, healing allies within 8 yds for 486.
    astral_influence              = { 82210, 197524, 2 }, -- Increases the range of all of your abilities by 1/2 yards.
    berserk_persistence           = { 82144, 377779, 1 }, -- Go berserk for 15 sec, reducing the cooldown of Frenzied Regeneration by 100% and cost of Ironfur by 50%. Combines with other Berserk abilities.
    berserk_ravage                = { 82149, 343240, 1 }, -- Go berserk for 15 sec, reducing the cooldowns of Mangle, Thrash, and Growl by 100%. Combines with other Berserk abilities.
    berserk_unchecked_aggression  = { 82155, 377623, 1 }, -- Go berserk for 15 sec, increasing haste by 15%, and reducing the rage cost of Maul by 50%. Combines with other Berserk abilities.
    blood_frenzy                  = { 82142, 203962, 1 }, -- Thrash also generates 2 Rage each time it deals damage.
    brambles                      = { 82161, 203953, 1 }, -- Sharp brambles protect you, absorbing and reflecting up to 29 damage from each attack. While Barkskin is active, the brambles also deal 13 Nature damage to all nearby enemies every 1 sec.
    bristling_fur                 = { 82161, 155835, 1 }, -- Bristle your fur, causing you to generate Rage based on damage taken for 8 sec.
    circle_of_life_and_death      = { 82137, 391969, 1 }, -- Your damage over time effects deal their damage in 25% less time, and your healing over time effects in 15% less time.
    convoke_the_spirits           = { 82136, 391528, 1 }, -- Call upon the Night Fae for an eruption of energy, channeling a rapid flurry of 16 Druid spells and abilities over 4 sec. You will cast Mangle, Ironfur, Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    cyclone                       = { 82213, 33786 , 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to 6 sec. Only one target can be affected by your Cyclone at a time.
    dream_of_cenarius             = { 82151, 372119, 1 }, -- When you take non-periodic damage, you have a chance equal to your critical strike to cause your next Regrowth to be instant, free, and castable in all forms for 30 sec. This effect cannot occur more than once every 20 sec.
    earthwarden                   = { 82156, 203974, 1 }, -- When you deal direct damage with Thrash, you gain a charge of Earthwarden, reducing the damage of the next auto attack you take by 30%. Earthwarden may have up to 3 charges.
    elunes_favored                = { 82134, 370586, 1 }, -- While in Bear Form, you deal 10% increased Arcane damage, and are healed for 30% of all Arcane damage done.
    feline_swiftness              = { 82239, 131768, 2 }, -- Increases your movement speed by 15%.
    flashing_claws                = { 82157, 393427, 2 }, -- Thrash has a 10% chance to trigger an additional Thrash.
    frenzied_regeneration         = { 82220, 22842 , 1 }, -- Heals you for 32% health over 3 sec.
    front_of_the_pack             = { 82125, 377835, 1 }, -- Stampeding Roar's radius and duration are increased by 15%. Your movement speed is increased by 5%.
    fury_of_nature                = { 82138, 370695, 2 }, -- While in Bear From, you deal 10% increased Arcane damage.
    galactic_guardian             = { 82147, 203964, 1 }, -- Your damage has a 5% chance to trigger a free automatic Moonfire on that target. When this occurs, the next Moonfire you cast generates 8 Rage, and deals 300% increased direct damage.
    gore                          = { 82126, 210706, 1 }, -- Thrash, Swipe, Moonfire, and Maul have a 15% chance to reset the cooldown on Mangle, and to cause it to generate an additional 4 Rage.
    gory_fur                      = { 82132, 200854, 1 }, -- Mangle has a 15% chance to reduce the Rage cost of your next Ironfur by 25%.
    guardian_of_elune             = { 82140, 155578, 1 }, -- Mangle increases the duration of your next Ironfur by 2 sec, or the healing of your next Frenzied Regeneration by 20%.
    heart_of_the_wild             = { 82231, 319454, 1 }, -- TODO: (mana costs) Abilities not associated with your specialization are substantially empowered for 45 sec. Balance: Magical damage increased by 30%. Feral: Physical damage increased by 30%. Restoration: Healing increased by 30%, and mana costs reduced by 50%.
    hibernate                     = { 82211, 2637  , 1 }, -- Forces the enemy target to sleep for up to 40 sec. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin             = { 82219, 327993, 1 }, -- Barkskin's duration is increased by 4 sec.
    improved_rejuvenation         = { 82240, 231040, 1 }, -- Rejuvenation's duration is increased by 3 sec.
    improved_stampeding_roar      = { 82230, 288826, 1 }, -- Cooldown reduced by 60 sec.
    improved_sunfire              = { 82207, 231050, 1 }, -- Sunfire now applies its damage over time effect to all enemies within 8 yards.
    improved_survival_instincts   = { 82128, 328767, 1 }, -- Survival Instincts now has 2 charges.
    incapacitating_roar           = { 82237, 99    , 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 10 yards for 3 sec. Damage will cancel the effect.
    incarnation_guardian_of_ursoc = { 82136, 394786, 1 }, -- An improved Bear Form that grants the benefits of Berserk, causes Mangle to hit up to 3 targets, and increases maximum health by 30%. Lasts 30 sec. You may freely shapeshift in and out of this improved Bear Form for its duration.
    infected_wounds               = { 82162, 345208, 1 }, -- Mangle and Maul cause an Infected Wound in the target, reducing their movement speed by 50% for 12 sec.
    innate_resolve                = { 82160, 377811, 1 }, -- Regrowth and Frenzied Regeneration healing is increased by 20.0% on yourself. Frenzied Regeneration has 1 additional charge.
    innervate                     = { 82243, 29166 , 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 10 sec.
    ironfur                       = { 82227, 192081, 1 }, -- Increases armor by 448 for 7 sec.
    killer_instinct               = { 82225, 108299, 3 }, -- Physical damage and Armor increased by 2%.
    layered_mane                  = { 82148, 384721, 2 }, -- Ironfur has a 10.0% chance to apply two stacks and Frenzied Regeneration has a 10% chance to not consume a charge.
    lycaras_teachings             = { 82233, 378988, 3 }, -- You gain 2% of a stat while in each form: No Form: Haste Cat Form: Critical Strike Bear Form: Versatility Moonkin Form: Mastery
    maim                          = { 82221, 22570 , 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point: 1 point : 60 damage, 1 sec 2 points: 119 damage, 2 sec 3 points: 179 damage, 3 sec 4 points: 238 damage, 4 sec 5 points: 298 damage, 5 sec
    mangle                        = { 82131, 231064, 1 }, -- Mangle deals 20% additional damage against bleeding targets.
    mass_entanglement             = { 82242, 102359, 1 }, -- Roots the target and all enemies within 15 yards in place for 30 sec. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                    = { 82236, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb 1,227 damage for 8 sec.
    maul                          = { 82127, 6807  , 1 }, -- Maul the target for 420 Physical damage.
    mighty_bash                   = { 82237, 5211  , 1 }, -- Invokes the spirit of Ursoc to stun the target for 4 sec. Usable in all shapeshift forms.
    moonkin_form                  = { 91043, 197625, 1 }, -- Shapeshift into Moonkin Form, increasing your armor by 125%, and granting protection from Polymorph effects. The act of shapeshifting frees you from movement impairing effects.
    natural_recovery              = { 82206, 377796, 2 }, -- Healing done and healing taken increased by 3%.
    natures_vigil                 = { 82244, 124974, 1 }, -- For 30 sec, all single-target damage also heals a nearby friendly target for 20% of the damage done.
    nurturing_instinct            = { 82214, 33873 , 3 }, -- Magical damage and healing increased by 2%.
    primal_fury                   = { 82238, 159286, 1 }, -- When you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect.
    protector_of_the_pack         = { 82245, 378986, 1 }, -- Store 10% of your damage, up to 560. Your next Regrowth consumes all stored damage to increase its healing.
    pulverize                     = { 82153, 80313 , 1 }, -- A devastating blow that consumes 2 stacks of your Thrash on the target to deal 475 Physical damage and reduce the damage they deal to you by 35% for 10 sec.
    rage_of_the_sleeper           = { 82141, 200851, 1 }, -- Unleashes the rage of Ursoc for 10 sec, preventing 25% of all damage you take and reflecting 231 Nature damage back at your attackers.
    rake                          = { 82199, 1822  , 1 }, -- Rake the target for 78 Bleed damage and an additional 567 Bleed damage over 15 sec. While stealthed, Rake will also stun the target for 4 sec and deal 60% increased damage. Awards 1 combo point.
    reinforced_fur                = { 82139, 393618, 1 }, -- Ironfur increases armor by an additional 4% and Barkskin reduces damage taken by an additional 5%.
    reinvigoration                = { 82154, 372945, 2 }, -- Frenzied Regeneration's cooldown is reduced by 10%.
    rejuvenation                  = { 82217, 774   , 1 }, -- Heals the target for 580 over 12 sec.
    remove_corruption             = { 82215, 2782  , 1 }, -- Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    rend_and_tear                 = { 82152, 204053, 1 }, -- Each stack of Thrash reduces the target's damage to you by 2% and increases your damage to them by 2%.
    renewal                       = { 82232, 108238, 1 }, -- Instantly heals you for 30% of maximum health. Usable in all shapeshift forms.
    rip                           = { 82222, 1079  , 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point. 1 point : 359 over 8 sec 2 points: 539 over 12 sec 3 points: 719 over 16 sec 4 points: 898 over 20 sec 5 points: 1,077 over 24 sec
    scintillating_moonlight       = { 82146, 238049, 2 }, -- Moonfire reduces damage dealt to you by -1%.
    skull_bash                    = { 82224, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for 4 sec.
    soothe                        = { 82229, 2908  , 1 }, -- Soothes the target, dispelling all enrage effects.
    soul_of_the_forest            = { 82142, 158477, 1 }, -- Mangle generates 5 more Rage and deals 25% more damage.
    stampeding_roar               = { 82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within 15 yards by 60% for 8 sec.
    starfire                      = { 91041, 197628, 1 }, -- Call down a burst of energy, causing 413 Arcane damage to the target, and 141 Arcane damage to all other enemies within 5 yards.
    starsurge                     = { 82200, 197626, 1 }, -- Launch a surge of stellar energies at the target, dealing 764 Astral damage.
    sunfire                       = { 82208, 93402 , 1 }, -- A quick beam of solar light burns the enemy for 94 Nature damage and then an additional 738 Nature damage over 18 sec.
    survival_instincts            = { 82129, 61336 , 1 }, -- Reduces all damage you take by 50% for 6 sec.
    survival_of_the_fittest       = { 82143, 203965, 2 }, -- Reduces the cooldowns of Barkskin and Survival Instincts by 15%.
    swiftmend                     = { 82216, 18562 , 1 }, -- Consumes a Regrowth, Wild Growth, or Rejuvenation effect to instantly heal an ally for 1,625.
    swipe                         = { 82226, 213764, 1 }, -- Swipe nearby enemies, inflicting Physical damage. Damage varies by shapeshift form.
    thick_hide                    = { 82228, 16931 , 2 }, -- Reduces all damage taken by 6%.
    thrash                        = { 82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    tiger_dash                    = { 82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by 200%, reducing gradually over 5 sec.
    tireless_pursuit              = { 82197, 377801, 1 }, -- For 3 sec after leaving Cat Form or Travel Form, you retain up to 40% movement speed.
    tooth_and_claw                = { 82159, 135288, 1 }, -- Autoattacks have a 20% chance to empower your next Maul, stacking up to 2 times. Empowered Maul deals 40% increased damage and reduces the target's damage to you by 15% for 6 sec.
    twin_moonfire                 = { 82145, 372567, 1 }, -- Moonfire deals 20% increased damage and also hits another nearby enemy within 15 yds of the target.
    typhoon                       = { 82209, 132469, 1 }, -- Blasts targets within 15 yards in front of you with a violent Typhoon, knocking them back and dazing them for 6 sec. Usable in all shapeshift forms.
    untamed_savagery              = { 82152, 372943, 1 }, -- Increases the damage and radius of Thrash by 25%.
    ursine_adept                  = { 82150, 300346, 1 }, -- Moonfire, Soothe, Remove Corruption, and Rebirth are usable in Bear Form. Multiple uses of Ironfur may overlap. All damage taken in Bear Form reduced by 10%.
    ursine_vigor                  = { 82235, 377842, 2 }, -- For 4 sec after shifting into Bear Form, your health and armor are increased by 10%.
    ursocs_endurance              = { 82130, 393611, 2 }, -- Increases the duration of Barkskin and Ironfur by 1.0 sec.
    ursocs_fury                   = { 82151, 377210, 1 }, -- Thrash and Maul grant you an absorb shield for 30% of the damage dealt for 15 sec.
    ursocs_guidance               = { 82135, 393414, 1 }, -- Incarnation: Guardian of Ursoc: Every 20 Rage you spend reduces the cooldown of Incarnation: Guardian of Ursoc by 1 sec.  Convoke the Spirits: Convoke the Spirits' cooldown is reduced by 50% and its duration and number of spells cast is reduced by 25%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    ursols_vortex                 = { 82242, 102793, 1 }, -- Conjures a vortex of wind for 10 sec at the destination, reducing the movement speed of all enemies within 8 yards by 50%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart                 = { 82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by 20%.
    vicious_cycle                 = { 82158, 371999, 1 }, -- Mangle increases the damage of your next Maul, and Maul increases the damage of your next Mangle by 15%. Stacks up to 3.
    vulnerable_flesh              = { 82133, 372618, 2 }, -- Maul has an additional 30% chance to critically strike.
    wellhoned_instincts           = { 82246, 377847, 2 }, -- When you fall below 40% health, you cast Frenzied Regeneration, up to once every 120 sec.
    wild_charge                   = { 82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                   = { 82241, 48438 , 1 }, -- Heals up to 5 injured allies within 30 yards of the target for 461 over 7 sec. Healing starts high and declines over the duration.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    alpha_challenge     = 842 , -- (207017) You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    charging_bash       = 194 , -- (228431) Increases the range of your Skull Bash by 10 yards.
    demoralizing_roar   = 52  , -- (201664) Demoralizes all enemies within 10 yards, reducing the damage they do by 20% for 8 sec.
    den_mother          = 51  , -- (236180) You bolster nearby allies within 15 yards, increasing their maximum health by 15%.
    emerald_slumber     = 197 , -- (329042) Embrace the Emerald Dream, causing you to enter a deep slumber for 8 sec. While sleeping, all other cooldowns recover 400% faster, and allies within 40 yds are healed for 291 every 1 sec. Direct damage taken may awaken you.
    entangling_claws    = 195 , -- (202226) Entangling Roots is now an instant cast spell with a 6 second cooldown but with a 10 yard range. It can also be cast while in shapeshift forms.
    freedom_of_the_herd = 3750, -- (213200) Your Stampeding Roar clears all roots and snares from yourself and allies.
    grove_protection    = 5410, -- (354654) Summon a grove to protect allies in the area for 10 sec, reducing damage taken by 40% from enemies outside the grove.
    malornes_swiftness  = 1237, -- (236147) Your Travel Form movement speed while within a Battleground or Arena is increased by 20% and you always move at 100% movement speed while in Travel Form.
    master_shapeshifter = 49  , -- (236144) Your Feral, Balance or Restoration Affinity is amplified granting an additional effect.  Restoration Affinity After you Swiftmend, the cast time of your Regrowth is reduced by 30% and its healing is increased by 30% for 8 sec.  Balance Affinity After you enter Moonkin Form, the cast time of your Wrath and Starfire is reduced by 30% and their damage is increased by 20% for 10 sec.  Feral Affinity While in Cat Form, your bleed damage is increased by 30%.
    overrun             = 196 , -- (202246) Charge to an enemy, stunning them for 3 sec and knocking back their allies within 15 yards.
    raging_frenzy       = 192 , -- (236153) Your Frenzied Regeneration also generates 60 Rage over 3 sec.
    reactive_resin      = 5524, -- (203399) Casting Rejuvenation grants the target 2 charges of Reactive Resin. Reactive Resin will heal the target for 254 after taking a melee critical strike, and increase the duration of Rejuvenation by 3 sec.
    sharpened_claws     = 193 , -- (202110) Maul increases the damage done by your Swipe and Thrash by 25% for 6 sec.
    toughness           = 50  , -- (201259) The duration of all stun effects are reduced by 25%.
} )


local mod_circle_hot = setfenv( function( x )
    return x * ( legendary.circle_of_life_and_death.enabled and 0.85 or 1 ) * ( talent.circle_of_life_and_death.enabled and 0.85 or 1 )
end, state )

local mod_circle_dot = setfenv( function( x )
    return x * ( legendary.circle_of_life_and_death.enabled and 0.75 or 1 ) * ( talent.circle_of_life_and_death.enabled and 0.75 or 1 )
end, state )


-- Auras
spec:RegisterAuras( {
    aquatic_form = {
        id = 276012,
        duration = 3600,
        max_stack = 1,
    },
    -- All damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=22812
    barkskin = {
        id = 22812,
        duration = function() return ( talent.improved_barkskin.enabled and 12 or 8 ) + talent.ursocs_endurance.rank end,
        type = "Magic",
        max_stack = 1
    },
    -- Armor increased by $w4%.  Stamina increased by $1178s2%.  Immune to Polymorph effects.
    -- https://wowhead.com/beta/spell=5487
    bear_form = {
        id = 5487,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Berserk. $?a377623[Haste increased by $s4%. ][]$?a343240|(a343240&a377779)[Cooldowns of ][]$?a377779&!a343240[Cooldown of ][]$?a377779[Frenzied Regeneration][]$?a343240&a377779[, ][]$?a343240[Mangle, Thrash, and Growl][]$?a377779|a343240[ reduced by $s2%][]$?a377779|a377623[Cost of ][]$?a377623[Maul][]$?a377623&a377779[ and ][]$?a377779[Ironfur][]$?a377779|a377623[ reduced by $s3%][].$?a339062[    Immune to effects that cause loss of control of your character.][]
    -- https://wowhead.com/beta/spell=50334
    berserk = {
        id = 50334,
        duration = 15,
        max_stack = 1
    },
    -- Alias for Berserk vs. Incarnation
    berserk_bear = {
        alias = { "berserk", "incarnation" },
        aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff",
        duration = function () return talent.incarnation.enabled and 30 or 15 end,
    },
    -- Talent: Generating Rage from taking damage.
    -- https://wowhead.com/beta/spell=155835
    bristling_fur = {
        id = 155835,
        duration = 8,
        max_stack = 1
    },
    -- Autoattack damage increased by $w4%.  Immune to Polymorph effects.  Movement speed increased by $113636s1% and falling damage reduced.
    -- https://wowhead.com/beta/spell=768
    cat_form = {
        id = 768,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Taking damage will grant $102352m1 healing every $102352t sec for $102352d.
    -- https://wowhead.com/beta/spell=102351
    cenarion_ward = {
        id = 102351,
        duration = 30,
        max_stack = 1
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=102352
    cenarion_ward = {
        id = 102352,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent / Covenant (Night Fae): Every ${$t1}.2 sec, casting $?a24858|a197625[Starsurge, Starfall,]?a768[Ferocious Bite, Shred, Tiger's Fury,]?a5487[Mangle, Ironfur,][Wild Growth, Swiftmend,] Moonfire, Wrath, Regrowth, Rejuvenation, Rake or Thrash on appropriate nearby targets.
    -- https://wowhead.com/beta/spell=323764
    convoke_the_spirits = {
        id = 391528,
        duration = 4,
        max_stack = 1,
        copy = 323764
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=200389
    cultivation = {
        id = 200389,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Disoriented and invulnerable.
    -- https://wowhead.com/beta/spell=33786
    cyclone = {
        id = 33786,
        duration = 6,
        mechanic = "banish",
        type = "Magic",
        max_stack = 1
    },
    -- Increased movement speed by $s1% while in Cat Form.
    -- https://wowhead.com/beta/spell=1850
    dash = {
        id = 1850,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    dream_of_cenarius = {
        id = 372152,
        duration = 30,
        max_stack = 1
    },
    earthwarden = {
        id = 203975,
        duration = 3600,
        max_stack = 3
    },
    -- Rooted.$?<$w2>0>[ Suffering $w2 Nature damage every $t2 sec.][]
    -- https://wowhead.com/beta/spell=339
    entangling_roots = {
        id = 339,
        duration = 30,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Bleeding for $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=274838
    feral_frenzy = {
        id = 274838,
        duration = 6,
        max_stack = 1
    },
    flight_form = {
        id = 276029,
        duration = 3600,
        max_stack = 1,
    },
    -- Bleeding for $w1 damage every $t sec.
    -- https://wowhead.com/beta/spell=391140
    frenzied_assault = {
        id = 391140,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Talent: Healing $w1% health every $t1 sec.
    -- https://wowhead.com/beta/spell=22842
    frenzied_regeneration = {
        id = 22842,
        duration = 3,
        max_stack = 1
    },
    -- Movement speed reduced by $s2%. Suffering $w1 Nature damage every $t1 sec.
    -- https://wowhead.com/beta/spell=81281
    fungal_growth = {
        id = 81281,
        duration = 8,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Generating ${$m3/10/$t3*$d} Astral Power over $d.
    -- https://wowhead.com/beta/spell=202770
    fury_of_elune = {
        id = 202770,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    galactic_guardian = {
        id = 213708,
        duration = 15,
        max_stack = 1,
    },
    gore = {
        id = 93622,
        duration = 10,
        max_stack = 1,
    },
    -- Talent: Reduces the Rage cost of your next Ironfur by $s1%.
    -- https://wowhead.com/beta/spell=201671
    gory_fur = {
        id = 201671,
        duration = 3600,
        max_stack = 1
    },
    -- Heals $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=279793
    grove_tending = {
        id = 279793,
        duration = 9,
        max_stack = 1
    },
    -- Heals $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=383193
    grove_tending = {
        id = 383193,
        duration = 9,
        max_stack = 1
    },
    -- Taunted.
    -- https://wowhead.com/beta/spell=6795
    growl = {
        id = 6795,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    -- Talent: Increases the duration of your next Ironfur by ${$m1/1000} sec, or the healing of your next Frenzied Regeneration by $s2%.
    -- https://wowhead.com/beta/spell=213680
    guardian_of_elune = {
        id = 213680,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Abilities not associated with your specialization are substantially empowered.
    -- https://wowhead.com/beta/spell=319454
    heart_of_the_wild = {
        id = 319454,
        duration = 45,
        type = "Magic",
        max_stack = 1,
        copy = { 319451, 319452, 319453 }
    },
    -- Talent: Asleep.
    -- https://wowhead.com/beta/spell=2637
    hibernate = {
        id = 2637,
        duration = 40,
        mechanic = "sleep",
        type = "Magic",
        max_stack = 1
    },
    immobilized = {
        id = 45334,
        duration = 4,
        max_stack = 1,
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=99
    incapacitating_roar = {
        id = 99,
        duration = 3,
        mechanic = "incapacitate",
        max_stack = 1
    },
    -- Talent: Cooldowns of Mangle, Thrash, Growl, and Frenzied Regeneration are reduced by $w1%.  Ironfur cost reduced by $w3%.  Mangle hits up to $w12 targets.  Health increased by $w13%.$?$w7>0[    Immune to effects that cause loss of control of your character.][]
    -- https://wowhead.com/beta/spell=102558
    incarnation = {
        id = 102558,
        duration = 30,
        max_stack = 1,
        copy = "incarnation_guardian_of_ursoc"
    },
    -- Talent: Movement speed slowed by $w1%.
    -- https://wowhead.com/beta/spell=345209
    infected_wounds = {
        id = 345209,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Mana costs reduced $w1%.
    -- https://wowhead.com/beta/spell=29166
    innervate = {
        id = 29166,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    intimidating_roar = {
        id = 236748,
        duration = 3,
        max_stack = 1,
    },
    -- Talent: Armor increased by ${$w1*$AGI/100}.
    -- https://wowhead.com/beta/spell=192081
    ironfur = {
        id = 192081,
        duration = function() return ( buff.guardian_of_elune.up and 9 or 7 ) + talent.ursocs_endurance.rank end,
        max_stack = 5,
    },
    -- Healing $w1 every $t1 sec.  Blooms for additional healing when effect expires or is dispelled.
    -- https://wowhead.com/beta/spell=33763
    lifebloom = {
        id = 33763,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Healing $w1 every $t1 sec.  Blooms for additional healing when effect expires or is dispelled.
    -- https://wowhead.com/beta/spell=188550
    lifebloom = {
        id = 188550,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Versatility increased by $w1%.
    -- https://wowhead.com/beta/spell=1126
    mark_of_the_wild = {
        id = 1126,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Rooted.
    -- https://wowhead.com/beta/spell=102359
    mass_entanglement = {
        id = 102359,
        duration = 30,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=385787
    matted_fur = {
        id = 385787,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=5211
    mighty_bash = {
        id = 5211,
        duration = 4,
        mechanic = "stun",
        max_stack = 1
    },
    -- Suffering $w1 Arcane damage every $t1 sec.
    -- https://wowhead.com/beta/spell=164812
    moonfire = {
        id = 164812,
        duration = function () return mod_circle_dot( 16 ) end,
        tick_time = function () return mod_circle_dot( 2 ) * haste end,
        type = "Magic",
        max_stack = 1,
        copy = 155625
    },
    -- Talent: Immune to Polymorph effects.$?$w3>0[  Armor increased by $w3%.][]
    -- https://wowhead.com/beta/spell=197625
    moonkin_form = {
        id = 197625,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $?s137012[Single-target healing also damages a nearby enemy target for $w3% of the healing done][Single-target damage also heals a nearby friendly target for $w3% of the damage done].
    -- https://wowhead.com/beta/spell=124974
    natures_vigil = {
        id = 124974,
        duration = 30,
        max_stack = 1
    },
    -- Stealthed.
    -- https://wowhead.com/beta/spell=5215
    prowl = {
        id = 5215,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Dealing $w2% reduced damage to $@auracaster.
    -- https://wowhead.com/beta/spell=80313
    pulverize = {
        id = 80313,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Prevents $s4% of all damage you take and reflects $219432s1 Nature damage back at your attackers.
    -- https://wowhead.com/beta/spell=200851
    rage_of_the_sleeper = {
        id = 200851,
        duration = 10,
        max_stack = 1
    },
    -- Heals $w2 every $t2 sec.
    -- https://wowhead.com/beta/spell=8936
    regrowth = {
        id = 8936,
        duration = function () return mod_circle_hot( 12 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Healing $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=774
    rejuvenation = {
        id = 774,
        duration = function () return mod_circle_hot( talent.improved_rejuvenation.enabled and 18 or 15 ) end,
        tick_time = function () return mod_circle_hot( 3 ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Healing $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=155777
    rejuvenation_germination = {
        id = 155777,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    -- Healing $s1 every $t sec.
    -- https://wowhead.com/beta/spell=364686
    renewing_bloom = {
        id = 364686,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Bleeding for $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=1079
    rip = {
        id = 1079,
        duration = 4,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Swipe and Thrash damage increased by $m1%.
    -- https://wowhead.com/beta/spell=279943
    sharpened_claws = {
        id = 279943,
        duration = 6,
        max_stack = 1
    },
    -- Dealing $s1 every $t1 sec.
    -- https://wowhead.com/beta/spell=363830
    sickle_of_the_lion = {
        id = 363830,
        duration = 10,
        tick_time = 1,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Interrupted.
    -- https://wowhead.com/beta/spell=97547
    solar_beam = {
        id = 97547,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=207386
    spring_blossoms = {
        id = 207386,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Movement speed increased by $s1%.
    -- https://wowhead.com/beta/spell=77764
    stampeding_roar = {
        id = 77761,
        duration = function() return ( talent.front_of_the_pack.enabled and 1.15 or 1 ) * 8 end,
        type = "Magic",
        max_stack = 1,
        copy = { 77764, 106898 }
    },
    -- Suffering $w2 Astral damage every $t2 sec.
    -- https://wowhead.com/beta/spell=202347
    stellar_flare = {
        id = 202347,
        duration = function () return mod_circle_dot( 24 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $w2 Nature damage every $t2 seconds.
    -- https://wowhead.com/beta/spell=164815
    sunfire = {
        id = 164815,
        duration = function () return mod_circle_dot( 12 ) end,
        tick_time = function () return mod_circle_dot( 2 ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $50322s1%.
    -- https://wowhead.com/beta/spell=61336
    survival_instincts = {
        id = 61336,
        duration = 6,
        max_stack = 1
    },
    -- Bleeding for $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=391356
    tear = {
        id = 391356,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Talent: Bleeding for $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=192090
    thrash_bear = {
        id = 192090,
        duration = function () return mod_circle_dot( 15 ) end,
        tick_time = function () return mod_circle_dot( 3 ) * haste end,
        max_stack = function () return legendary.luffainfused_embrace and 4 or 3 end,
    },
    -- Talent: Increased movement speed by $s1% while in Cat Form, reducing gradually over time.
    -- https://wowhead.com/beta/spell=252216
    tiger_dash = {
        id = 252216,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    tireless_pursuit = {
        id = 393897,
        duration = 3,
        max_stack = 1,
        copy = 340546
    },
    -- Talent: Your next Maul deals $s1% more damage and reduces the target's damage to you by $135601s1%~ for $135601d.
    -- https://wowhead.com/beta/spell=135286
    tooth_and_claw = {
        id = 135286,
        duration = 15,
        max_stack = 2
    },
    -- Talent: Dealing $w1% reduced damage to $@auracaster.
    -- https://wowhead.com/beta/spell=135601
    tooth_and_claw_debuff = {
        id = 135601,
        duration = 6,
        max_stack = 1
    },
    -- Immune to Polymorph effects.  Movement speed increased.
    -- https://wowhead.com/beta/spell=783
    travel_form = {
        id = 783,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Dazed.
    -- https://wowhead.com/beta/spell=61391
    typhoon = {
        id = 61391,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    ursocs_fury = {
        id = 372505,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Movement speed slowed by $s1% and winds impeding movement.
    -- https://wowhead.com/beta/spell=102793
    ursols_vortex = {
        id = 102793,
        duration = 10,
        type = "Magic",
        max_stack = 1,
        copy = 127797
    },
    vicious_cycle_mangle = {
        id = 372019,
        duration = 15,
        max_stack = 1,
    },
    vicious_cycle_maul = {
        id = 372015,
        duration = 15,
        max_stack = 1,
    },
    -- Talent: Flying to an ally's position.
    -- https://wowhead.com/beta/spell=102401
    wild_charge = {
        id = 102401,
        duration = 0.5,
        max_stack = 1
    },
    -- Talent: Heals $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=48438
    wild_growth = {
        id = 48438,
        duration = 7,
        type = "Magic",
        max_stack = 1
    },

    any_form = {
        alias = { "bear_form", "cat_form", "moonkin_form" },
        duration = 3600,
        aliasMode = "first",
        aliasType = "buff",
    },

    -- PvP Talents
    demoralizing_roar = {
        id = 201664,
        duration = 8,
        max_stack = 1,
    },
    den_mother = {
        id = 236181,
        duration = 3600,
        max_stack = 1,
    },
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 1,
    },
    grove_protection_defense = {
        id = 354704,
        duration = 12,
        max_stack = 1,
    },
    grove_protection_offense = {
        id = 354789,
        duration = 12,
        max_stack = 1,
    },
    master_shapeshifter_feral = {
        id = 236188,
        duration = 3600,
        max_stack = 1,
    },
    overrun = {
        id = 202244,
        duration = 3,
        max_stack = 1,
    },
    protector_of_the_pack = {
        id = 201940,
        duration = 3600,
        max_stack = 1,
    },
    sharpened_claws = {
        id = 279943,
        duration = 6,
        max_stack = 1,
    },

    -- Azerite
    masterful_instincts = {
        id = 273349,
        duration = 30,
        max_stack = 1,
    },

    -- Conduit
    savage_combatant = {
        id = 340613,
        duration = 15,
        max_stack = 3
    },
    wellhoned_instincts = {
        id = 340556,
        duration = function ()
            if conduit.wellhoned_instincts.enabled then return conduit.wellhoned_instincts.mod end
            return 90
        end,
        max_stack = 1
    },

    -- Legendary
    lycaras_fleeting_glimpse = {
        id = 340060,
        duration = 5,
        max_stack = 1
    },
    ursocs_fury_remembered = {
        id = 345048,
        duration = 15,
        max_stack = 1,
    }
} )

Hekili:EmbedAdaptiveSwarm( spec )

-- Function to remove any form currently active.
spec:RegisterStateFunction( "unshift", function()
    if ( talent.tireless_pursuit.enabled or conduit.tireless_pursuit.enabled ) and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

    removeBuff( "cat_form" )
    removeBuff( "bear_form" )
    removeBuff( "travel_form" )
    removeBuff( "moonkin_form" )
    removeBuff( "travel_form" )
    removeBuff( "aquatic_form" )
    removeBuff( "stag_form" )

    if legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent.restoration_affinity.enabled then
        applyBuff( "heart_of_the_wild" )
        applyDebuff( "player", "oath_of_the_elder_druid_icd" )
    end
end )


local affinities = {
    bear_form = "guardian_affinity",
    cat_form = "feral_affinity",
    moonkin_form = "balance_affinity",
}

-- Function to apply form that is passed into it via string.
spec:RegisterStateFunction( "shift", function( form )
    if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

    removeBuff( "cat_form" )
    removeBuff( "bear_form" )
    removeBuff( "travel_form" )
    removeBuff( "moonkin_form" )
    removeBuff( "travel_form" )
    removeBuff( "aquatic_form" )
    removeBuff( "stag_form" )
    applyBuff( form )

    if affinities[ form ] and legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent[ affinities[ form ] ].enabled then
        applyBuff( "heart_of_the_wild" )
        applyDebuff( "player", "oath_of_the_elder_druid_icd" )
    end
end )

spec:RegisterStateExpr( "ironfur_damage_threshold", function ()
    return ( settings.ironfur_damage_threshold or 0 ) / 100 * ( health.max )
end )


-- Gear.
-- Tier 28
spec:RegisterSetBonuses( "tier28_2pc", 364362, "tier28_4pc", 363496 )
-- 2-Set - Architect's Design - Casting Barkskin causes you to Berserk for 4 sec.
-- 4-Set - Architect's Aligner - While Berserked, you radiate (45%26.6% of Attack power) Cosmic damage to nearby enemies and heal yourself for (61%39.7% of Attack power) every 1 sec.
spec:RegisterAuras( {
    architects_aligner = {
        id = 363793,
        duration = function () return talent.incarnation.enabled and 30 or 15 end,
        max_stack = 1,
    },
    architects_aligner_heal = {
        id = 363789,
        duration = function () return talent.incarnation.enabled and 30 or 15 end,
        max_stack = 1,
    }
} )

spec:RegisterGear( "class", 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )
spec:RegisterGear( "tier19", 138330, 138336, 138366, 138324, 138327, 138333 )
spec:RegisterGear( "tier20", 147136, 147138, 147134, 147133, 147135, 147137 ) -- Bonuses NYI
spec:RegisterGear( "tier21", 152127, 152129, 152125, 152124, 152126, 152128 )

spec:RegisterGear( "ailuro_pouncers", 137024 )
spec:RegisterGear( "behemoth_headdress", 151801 )
spec:RegisterGear( "chatoyant_signet", 137040 )
spec:RegisterGear( "dual_determination", 137041 )
spec:RegisterGear( "ekowraith_creator_of_worlds", 137015 )
spec:RegisterGear( "elizes_everlasting_encasement", 137067 )
spec:RegisterGear( "fiery_red_maimers", 144354 )
spec:RegisterGear( "lady_and_the_child", 144295 )
spec:RegisterGear( "luffa_wrappings", 137056 )
spec:RegisterGear( "oakhearts_puny_quods", 144432 )
    spec:RegisterAura( "oakhearts_puny_quods", {
        id = 236479,
        duration = 3,
        max_stack = 1,
    } )
spec:RegisterGear( "skysecs_hold", 137025 )
    spec:RegisterAura( "skysecs_hold", {
        id = 208218,
        duration = 3,
        max_stack = 1,
    } )

spec:RegisterGear( "the_wildshapers_clutch", 137094 )

spec:RegisterGear( "soul_of_the_archdruid", 151636 )


spec:RegisterStateExpr( "lunar_eclipse", function ()
    return eclipse.wrath_counter
end )

spec:RegisterStateExpr( "solar_eclipse", function ()
    return eclipse.starfire_counter
end )

local LycarasHandler = setfenv( function ()
    if buff.travel_form.up then state:RunHandler( "stampeding_roar" )
    elseif buff.moonkin_form.up then state:RunHandler( "starfall" )
    elseif buff.bear_form.up then state:RunHandler( "barkskin" )
    elseif buff.cat_form.up then state:RunHandler( "primal_wrath" )
    else state:RunHandle( "wild_growth" ) end
end, state )

local SinfulHysteriaHandler = setfenv( function ()
    applyBuff( "ravenous_frenzy_sinful_hysteria" )
end, state )

spec:RegisterHook( "reset_precast", function ()
    if azerite.masterful_instincts.enabled and buff.survival_instincts.up and buff.masterful_instincts.down then
        applyBuff( "masterful_instincts", buff.survival_instincts.remains + 30 )
    end

    if buff.lycaras_fleeting_glimpse.up then
        state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
    end

    if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
        state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
    end

    eclipse.reset() -- from Balance.
end )


spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if not a or a.startsCombat then
        break_stealth()
    end

    if buff.ravenous_frenzy.up and ability ~= "ravenous_frenzy" then
        addStack( "ravenous_frenzy", nil, 1 )
    end
end )


spec:RegisterStateTable( "druid", setmetatable( {
}, {
    __index = function( t, k )
        if k == "catweave_bear" then
            return talent.feral_affinity.enabled and settings.catweave_bear
        elseif k == "owlweave_bear" then
            return talent.balance_affinity.enabled and settings.owlweave_bear
        elseif k == "no_cds" then return not toggle.cooldowns
        elseif k == "primal_wrath" then return debuff.rip
        elseif k == "lunar_inspiration" then return debuff.moonfire_cat end

        local fallthru = rawget( debuff, k )
        if fallthru then return fallthru end
    end
} ) )


-- Abilities
spec:RegisterAbilities( {
    alpha_challenge = {
        id = 207017,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        pvptalent = "alpha_challenge",

        startsCombat = true,
        texture = 132270,

        handler = function ()
            applyDebuff( "target", "focused_assault" )
        end,
    },

    -- Your skin becomes as tough as bark, reducing all damage you take by $s1% and preventing damage from delaying your spellcasts. Lasts $d.    Usable while stunned, frozen, incapacitated, feared, or asleep, and in all shapeshift forms.
    barkskin = {
        id = 22812,
        cast = 0,
        cooldown = function () return 60 * ( 1 - 0.15 * talent.survival_of_the_fittest.rank ) * ( 1 + ( conduit.tough_as_bark.mod * 0.01 ) ) end,
        gcd = "off",
        school = "nature",

        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        usable = function ()
            if not tanking then return false, "player is not tanking right now"
            elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
            return true
        end,
        handler = function ()
            applyBuff( "barkskin" )

            if legendary.the_natural_orders_will.enabled and buff.bear_form.up then
                applyBuff( "ironfur" )
                applyBuff( "frenzied_regeneration" )
            end

            if talent.matted_fur.enabled then applyBuff( "matted_fur" ) end
        end
    },

    -- Shapeshift into Bear Form, increasing armor by $m4% and Stamina by $1178s2%, granting protection from Polymorph effects, and increasing threat generation.    The act of shapeshifting frees you from movement impairing effects.
    bear_form = {
        id = 5487,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = -25,
        spendType = "rage",

        startsCombat = false,

        essential = true,
        noform = "bear_form",

        handler = function ()
            shift( "bear_form" )
            if talent.ursine_vigor.enabled or conduit.ursine_vigor.enabled then applyBuff( "ursine_vigor" ) end
        end,
    },

    berserk = {
        id = 50334,
        cast = 0,
        cooldown = function () return legendary.legacy_of_the_sleeper.enabled and 150 or 180 end,
        gcd = "off",

        toggle = "cooldowns",

        startsCombat = true,
        texture = 236149,

        notalent = "incarnation",

        handler = function ()
            applyBuff( "berserk" )
        end,

        copy = "berserk_bear"
    },

    -- Talent: Bristle your fur, causing you to generate Rage based on damage taken for $d.
    bristling_fur = {
        id = 155835,
        cast = 0,
        cooldown = 40,
        gcd = "spell",
        school = "nature",

        talent = "bristling_fur",
        startsCombat = false,

        usable = function ()
            if incoming_damage_3s < health.max * 0.1 then return false, "player has not taken 10% health in dmg in 3s" end
            return true
        end,
        handler = function ()
            applyBuff( "bristling_fur" )
        end,
    },

    -- Shapeshift into Cat Form, increasing auto-attack damage by $s4%, movement speed by $113636s1%, granting protection from Polymorph effects, and reducing falling damage.    The act of shapeshifting frees you from movement impairing effects.
    cat_form = {
        id = 768,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        startsCombat = false,

        noform = "cat_form",

        handler = function ()
            shift( "cat_form" )
            if pvptalent.master_shapeshifter.enabled and talent.feral_affinity.enabled then
                applyBuff( "master_shapeshifter_feral" )
            end
        end,
    },

    -- Talent / Covenant (Night_Fae): Call upon the Night Fae for an eruption of energy, channeling a rapid flurry of $s2 Druid spells and abilities over $d.    You will cast $?a24858|a197625[Starsurge, Starfall,]?a768[Ferocious Bite, Shred, Tiger's Fury,]?a5487[Mangle, Ironfur,][Wild Growth, Swiftmend,] Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    convoke_the_spirits = {
        id = function() return talent.convoke_the_spirits.enabled and 391528 or 323764 end,
        cast = function() return legendary.celestial_spirits.enabled and 3 or 4 end,
        channeled = true,
        cooldown = function () return legendary.celestial_spirits.enabled and 60 or 120 end,
        gcd = "spell",
        school = "nature",

        talent = "convoke_the_spirits",
        startsCombat = false,

        toggle = "cooldowns",

        disabled = function ()
            return not talent.convoke_the_spirits.enabled and covenant.night_fae and not IsSpellKnownOrOverridesKnown( 323764 ), "you have not finished your night_fae covenant intro"
        end,

        finish = function ()
            -- Can we safely assume anything is going to happen?
            if state.spec.feral then
                applyBuff( "tigers_fury" )
                if target.distance < 8 then
                    gain( 5, "combo_points" )
                end
            elseif state.spec.guardian then
            elseif state.spec.balance then
            end
        end,

        copy = { 391528, 323764 }
    },

    -- Talent: Tosses the enemy target into the air, disorienting them but making them invulnerable for up to $d. Only one target can be affected by your Cyclone at a time.
    cyclone = {
        id = 33786,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.1,
        spendType = "mana",

        talent = "cyclone",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "cyclone" )
        end,
    },

    -- Shift into Cat Form and increase your movement speed by $s1% while in Cat Form for $d.
    dash = {
        id = 1850,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "physical",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            if buff.cat_form.down then shift( "cat_form" ) end
            applyBuff( "dash" )
        end,
    },


    demoralizing_roar = {
        id = 201664,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        pvptalent = "demoralizing_roar",

        startsCombat = true,
        texture = 132117,

        handler = function ()
            applyDebuff( "demoralizing_roar" )
            active_dot.demoralizing_roar = active_enemies
        end,
    },


    emerald_slumber = {
        id = 329042,
        cast = 8,
        cooldown = 120,
        channeled = true,
        gcd = "spell",

        toggle = "cooldowns",
        pvptalent = "emerald_slumber",

        startsCombat = false,
        texture = 1394953,

        handler = function ()
        end,
    },

    -- Roots the target in place for $d. Damage may cancel the effect.$?s33891[    |C0033AA11Tree of Life: Instant cast.|R][]
    entangling_roots = {
        id = 339,
        cast = function () return pvptalent.entangling_claws.enabled and 0 or 1.7 end,
        cooldown = function () return pvptalent.entangling_claws.enabled and 6 or 0 end,
        gcd = "spell",
        school = "nature",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "entangling_roots" )
        end,
    },

    -- Talent: Heals you for $o1% health over $d$?s301768[, and increases healing received by $301768s1%][].
    frenzied_regeneration = {
        id = 22842,
        cast = 0,
        charges = function () return talent.innate_resolve.enabled and 2 or nil end,
        cooldown = function () return 36 * ( buff.berserk.up and talent.berserk_persistence.enabled and 0 or 1 ) * ( 1 - 0.1 * talent.reinvigoration.rank ) end,
        recharge = function () return talent.innate_resolve.enabled and ( 36 * ( buff.berserk.up and talent.berserk_persistence.enabled and 0 or 1 ) ) or nil end,
        gcd = "spell",
        school = "physical",

        spend = 10,
        spendType = "rage",

        talent = "frenzied_regeneration",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        form = "bear_form",
        nobuff = "frenzied_regeneration",

        handler = function ()
            applyBuff( "frenzied_regeneration" )
            gain( health.max * 0.08, "health" )
        end,
    },


    grove_protection = {
        id = 354654,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        toggle = "defensives",

        pvptalent = "grove_protection",
        startsCombat = false,
        texture = 4067364,

        handler = function ()
            -- Don't apply auras; position dependent.
        end,
    },

    -- Taunts the target to attack you.
    growl = {
        id = 6795,
        cast = 0,
        cooldown = function () return ( buff.berserk_bear.up and talent.berserk_ravage.enabled and 0 or 8 ) * haste end,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        handler = function ()
            applyBuff( "growl" )
        end,
    },

    -- Talent: Abilities not associated with your specialization are substantially empowered for $d.$?!s137013[    |cFFFFFFFFBalance:|r Magical damage increased by $s1%.][]$?!s137011[    |cFFFFFFFFFeral:|r Physical damage increased by $s4%.][]$?!s137010[    |cFFFFFFFFGuardian:|r Bear Form gives an additional $s7% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has ${$s9+1} charges.][]$?!s137012[    |cFFFFFFFFRestoration:|r Healing increased by $s10%, and mana costs reduced by $s12%.][]
    heart_of_the_wild = {
        id = 319454,
        cast = 0,
        cooldown = function () return 300 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
        gcd = "spell",
        school = "nature",

        talent = "heart_of_the_wild",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "heart_of_the_wild" )

            if talent.balance_affinity.enabled then
                shift( "moonkin_form" )
            elseif talent.feral_affinity.enabled then
                shift( "cat_form" )
            elseif talent.restoration_affinity.enabled then
                unshift()
            end
        end,
    },

    -- Talent: Forces the enemy target to sleep for up to $d.  Any damage will awaken the target.  Only one target can be forced to hibernate at a time.  Only works on Beasts and Dragonkin.
    hibernate = {
        id = 2637,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.06,
        spendType = "mana",

        talent = "hibernate",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hibernate" )
        end,
    },

    -- Talent: Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within $A1 yards for $d. Damage will cancel the effect.
    incapacitating_roar = {
        id = 99,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        talent = "incapacitating_roar",
        startsCombat = false,

        handler = function ()
            if buff.bear_form.down then shift( "bear_form" ) end
            applyDebuff( "target", "incapacitating_roar" )
        end,
    },


    incarnation = {
        id = 102558,
        cast = 0,
        cooldown = function () return legendary.legacy_of_the_sleeper.enabled and 150 or 180 end,
        gcd = "off",

        toggle = "cooldowns",

        startsCombat = false,
        texture = 571586,

        talent = "incarnation",

        handler = function ()
            applyBuff( "incarnation" )
            if set_bonus.tier28_4pc > 0 then
                applyBuff( "architects_aligner", buff.incarnation.remains )
                applyBuff( "architects_aligner_heal", buff.incarnation.remains )
            end
        end,

        copy = { "incarnation_guardian_of_ursoc", "Incarnation" }
    },

    -- Talent: Infuse a friendly healer with energy, allowing them to cast spells without spending mana for $d.$?s326228[    If cast on somebody else, you gain the effect at $326228s1% effectiveness.][]
    innervate = {
        id = 29166,
        cast = 0,
        cooldown = 180,
        gcd = "off",
        school = "nature",

        talent = "innervate",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "innervate" )
        end,
    },

    -- Talent: Increases armor by ${$s1*$AGI/100} for $d.$?a231070[ Multiple uses of this ability may overlap.][]
    ironfur = {
        id = 192081,
        cast = 0,
        cooldown = 0.5,
        gcd = "off",
        school = "nature",

        spend = function () return ( buff.berserk_bear.up and talent.berserk_persistence.enabled and 20 or 40 ) * ( buff.gory_fur.up and 0.85 or 1 ) end,
        spendType = "rage",

        talent = "ironfur",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        form = "bear_form",

        usable = function ()
            if not tanking then return false, "player is not tanking right now"
            elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
            return true
        end,

        handler = function ()
            applyBuff( "ironfur" )
            removeBuff( "gory_fur" )
            removeBuff( "guardian_of_elune" )
        end,
    },

    -- Talent: Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point:       1 point  : ${$s2*1} damage, 1 sec     2 points: ${$s2*2} damage, 2 sec     3 points: ${$s2*3} damage, 3 sec     4 points: ${$s2*4} damage, 4 sec     5 points: ${$s2*5} damage, 5 sec
    maim = {
        id = 22570,
        cast = 0,
        cooldown = 20,
        gcd = "totem",
        school = "physical",

        spend = 30,
        spendType = "energy",

        talent = "maim",
        startsCombat = false,

        form = "cat_form",

        usable = function () return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            applyDebuff( "target", "maim", combo_points.current )
            spend( combo_points.current, "combo_points" )
        end,
    },

    -- Talent: Mangle the target for $s2 Physical damage.$?a231064[ Deals $s3% additional damage against bleeding targets.][]    |cFFFFFFFFGenerates ${$m4/10} Rage.|r
    mangle = {
        id = 33917,
        cast = 0,
        cooldown = function () return ( buff.berserk_bear.up and talent.berserk_ravage.enabled and 0 or 6 ) * haste end,
        gcd = "spell",
        school = "physical",

        spend = function() return -10 - ( buff.gore.up and 4 or 0 ) - ( 5 * talent.soul_of_the_forest.rank ) end,
        spendType = "rage",

        talent = "mangle",
        startsCombat = true,

        form = "bear_form",

        handler = function ()
            removeBuff( "vicious_cycle_mangle" )
            addStack( "vicious_cycle_maul" )
            if talent.guardian_of_elune.enabled then applyBuff( "guardian_of_elune" ) end

            if buff.gore.up then
                gain( 4, "rage" )
                removeBuff( "gore" )
            end

            if talent.infected_wounds.enabled then applyDebuff( "target", "infected_wounds" ) end
            if conduit.savage_combatant.enabled then addStack( "savage_combatant", nil, 1 ) end
        end,
    },

    -- Infuse a friendly target with the power of the wild, increasing their Versatility by $s1% for 60 minutes.    If target is in your party or raid, all party and raid members will be affected.
    mark_of_the_wild = {
        id = 1126,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.2,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "mark_of_the_wild" )
        end,
    },

    -- Talent: Roots the target and all enemies within $A1 yards in place for $d. Damage may interrupt the effect. Usable in all shapeshift forms.
    mass_entanglement = {
        id = 102359,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        talent = "mass_entanglement",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mass_entanglement" )
        end,
    },

    -- Talent: Maul the target for $s2 Physical damage.
    maul = {
        id = 6807,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function() return buff.berserk_bear.up and talent.berserk_unchecked_aggression.enabled and 20 or 40 end,
        spendType = "rage",

        talent = "maul",
        startsCombat = true,

        form = "bear_form",

        usable = function ()
            if settings.maul_rage > 0 and rage.current - cost < settings.maul_rage then return false, "not enough additional rage" end
            return true
        end,

        handler = function ()
            removeBuff( "vicious_cycle_maul" )
            addStack( "vicious_cycle_mangle" )
            if talent.infected_wounds.enabled then applyDebuff( "target", "infected_wounds" ) end
            if pvptalent.sharpened_claws.enabled or essence.conflict_and_strife.major then applyBuff( "sharpened_claws" ) end
            if talent.ursocs_fury.enabled then applyBuff( "ursocs_fury" ) end
            removeBuff( "savage_combatant" )
        end,
    },

    -- Talent: Invokes the spirit of Ursoc to stun the target for $d. Usable in all shapeshift forms.
    mighty_bash = {
        id = 5211,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "physical",

        talent = "mighty_bash",
        startsCombat = true,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "mighty_bash" )
        end,
    },

    -- A quick beam of lunar light burns the enemy for $164812s1 Arcane damage and then an additional $164812o2 Arcane damage over $164812d$?s238049[, and causes enemies to deal $238049s1% less damage to you.][.]$?a372567[    Hits a second target within $279620s1 yds of the first.][]$?s197911[    |cFFFFFFFFGenerates ${$m3/10} Astral Power.|r][]
    moonfire = {
        id = 8921,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            if buff.bear_form.up and not talent.ursine_adept.enabled then unshift() end

            applyDebuff( "target", "moonfire" )

            if buff.galactic_guardian.up then
                gain( 8, "rage" )
                removeBuff( "galactic_guardian" )
            end

            if talent.twin_moonfire.enabled then
                active_dot.moonfire = min( true_active_enemies, active_dot.moonfire + 1 )
            end
        end,

        copy = 155625
    },

    -- Talent: Shapeshift into $?s114301[Astral Form][Moonkin Form], increasing your armor by $m3%, and granting protection from Polymorph effects.    The act of shapeshifting frees you from movement impairing effects.
    moonkin_form = {
        id = 197625,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        talent = "moonkin_form",
        startsCombat = false,

        noform = "moonkin_form",
        talent = "balance_affinity",

        handler = function ()
            shift( "moonkin_form" )
        end,
    },

    -- Talent: For $d, $?s137012[all single-target healing also damages a nearby enemy target for $s3% of the healing done][all single-target damage also heals a nearby friendly target for $s3% of the damage done].
    natures_vigil = {
        id = 124974,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "nature",

        talent = "natures_vigil",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "natures_vigil" )
        end,
    },


    overrun = {
        id = 202246,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        startsCombat = true,
        texture = 1408833,

        pvptalent = "overrun",

        handler = function ()
            applyDebuff( "target", "overrun" )
            setDistance( 5 )
        end,
    },

    -- Shift into Cat Form and enter stealth.
    prowl = {
        id = 5215,
        cast = 0,
        cooldown = 6,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        usable = function ()
            if time > 0 and ( not boss or not buff.shadowmeld.up ) then return false, "cannot stealth in combat"
            elseif buff.prowl.up then return false, "player is already prowling" end
            return true
        end,

        handler = function ()
            shift( "cat_form" )
            applyBuff( "prowl" )
        end,
    },

    -- Talent: A devastating blow that consumes $s3 stacks of your Thrash on the target to deal $s1 Physical damage and reduce the damage they deal to you by $s2% for $d.
    pulverize = {
        id = 80313,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "physical",

        talent = "pulverize",
        startsCombat = true,

        form = "bear_form",

        usable = function ()
            if debuff.thrash_bear.stack < 2 then return false, "target has fewer than 2 thrash stacks" end
            return true
        end,

        handler = function ()
            if debuff.thrash_bear.count > 2 then debuff.thrash_bear.count = debuff.thrash_bear.count - 2
            else removeDebuff( "target", "thrash_bear" ) end
            applyBuff( "pulverize" )
        end,
    },

    -- Talent: Unleashes the rage of Ursoc for $d, preventing $s4% of all damage you take and reflecting $219432s1 Nature damage back at your attackers.
    rage_of_the_sleeper = {
        id = 200851,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "physical",

        talent = "rage_of_the_sleeper",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "rage_of_the_sleeper" )
        end,
    },

    -- Heals a friendly target for $s1 and another ${$o2*$<mult>} over $d.$?s231032[ Initial heal has a $231032s1% increased chance for a critical effect if the target is already affected by Regrowth.][]$?s24858|s197625[ Usable while in Moonkin Form.][]$?s33891[    |C0033AA11Tree of Life: Instant cast.|R][]
    regrowth = {
        id = 8936,
        cast = function() return buff.dream_of_cenarius.up and 0 or 1.5 end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function() return buff.dream_of_cenarius.up and 0 or 0.17 end,
        spendType = "mana",

        startsCombat = false,

        talent = "restoration_affinity",
        usable = function ()
            if not ( buff.bear_form.down and buff.cat_form.down and buff.travel_form.down and buff.moonkin_form.down ) then return false, "player is in a form" end
            return true
        end,

        handler = function ()
            applyBuff( "regrowth" )
            removeBuff( "protector_of_the_pack" )
        end,
    },

    -- Talent: Heals the target for $o1 over $d.$?s155675[    You can apply Rejuvenation twice to the same target.][]$?s33891[    |C0033AA11Tree of Life: Healing increased by $5420s5% and Mana cost reduced by $5420s4%.|R][]
    rejuvenation = {
        id = 774,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.12,
        spendType = "mana",

        talent = "rejuvenation",
        startsCombat = false,

        usable = function ()
            if not ( buff.bear_form.down and buff.cat_form.down and buff.travel_form.down and buff.moonkin_form.down ) then return false, "player is in a form" end
            return true
        end,

        handler = function ()
            applyBuff( "rejuvenation" )
        end,
    },

    -- Talent: Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    remove_corruption = {
        id = 2782,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "arcane",

        spend = 0.065,
        spendType = "mana",

        talent = "remove_corruption",
        startsCombat = false,

        usable = function ()
            if buff.dispellable_poison.down and buff.dispellable_curse.down then return false, "player has no dispellable auras" end
            return true
        end,
        handler = function ()
            if buff.bear_form.up and not talent.ursine_adept.enabled then unshift() end
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_curse" )
        end,
    },

    -- Talent: Instantly heals you for $s1% of maximum health. Usable in all shapeshift forms.
    renewal = {
        id = 108238,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "nature",

        talent = "renewal",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        handler = function ()
            gain( 0.3 * health.max, "health" )
        end,
    },

    -- Talent: You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for $93985d.
    skull_bash = {
        id = 106839,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "skull_bash",
        startsCombat = false,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },

    -- Talent: Soothes the target, dispelling all enrage effects.
    soothe = {
        id = 2908,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "nature",

        spend = 0.056,
        spendType = "mana",

        talent = "soothe",
        startsCombat = false,

        debuff = "dispellable_enrage",

        handler = function ()
            if buff.bear_form.up and not talent.ursine_adept.enabled then unshift() end
            removeDebuff( "target", "dispellable_enrage" )
        end,
    },

    -- Talent: Let loose a wild roar, increasing the movement speed of all friendly players within $A1 yards by $s1% for $d.
    stampeding_roar = {
        id = 106898,
        cast = 0,
        cooldown = function () return 120 - ( talent.improved_stampeding_roar.enabled and 60 or 0 ) end,
        gcd = "spell",
        school = "physical",

        talent = "stampeding_roar",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "stampeding_roar" )
            if buff.bear_form.down and buff.cat_form.down then
                shift( "bear_form" )
            end
        end,

        copy = { 77761, 77764 }
    },

    -- Talent: Launch a surge of stellar energies at the target, dealing $s1 Astral damage, and empowering the damage bonus of any active Eclipse for its duration.
    starsurge = {
        id = 197626,
        cast = function () return buff.heart_of_the_wild.up and 0 or 2 end,
        cooldown = 0,
        gcd = "spell",
        school = "astral",

        spend = 40,
        spendType = "eclipse",

        talent = "starsurge",
        startsCombat = false,

        form = "moonkin_form",

        handler = function ()
            if buff.eclipse_solar.up then buff.eclipse_solar.empowerTime = query_time; applyBuff( "starsurge_empowerment_solar" ) end
            if buff.eclipse_lunar.up then buff.eclipse_lunar.empowerTime = query_time; applyBuff( "starsurge_empowerment_lunar" ) end
        end,
    },

    -- Talent: A quick beam of solar light burns the enemy for $164815s1 Nature damage and then an additional $164815o2 Nature damage over $164815d$?s231050[ to the primary target and all enemies within $164815A2 yards][].$?s137013[    |cFFFFFFFFGenerates ${$m3/10} Astral Power.|r][]
    sunfire = {
        id = 197630,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.12,
        spendType = "mana",

        talent = "sunfire",
        startsCombat = false,

        form = "moonkin_form",

        handler = function ()
            applyDebuff( "target", "sunfire" )
            active_dot.sunfire = active_enemies
        end,
    },

    -- Talent: Reduces all damage you take by $50322s1% for $50322d.
    survival_instincts = {
        id = 61336,
        cast = 0,
        charges = function() return talent.improved_survival_instincts.enabled and 2 or nil end,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( talent.survival_of_the_fittest.enabled and ( 2/3 ) or 1 ) * 180 end,
        recharge = function () return talent.improved_survival_instincts.enabled and ( ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( talent.survival_of_the_fittest.enabled and ( 2/3 ) or 1 ) * 180 ) or nil end,
        gcd = "off",
        school = "physical",

        talent = "survival_instincts",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        usable = function ()
            if not tanking then return false, "player is not tanking right now"
            elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
            return true
        end,

        handler = function ()
            applyBuff( "survival_instincts" )
            if talent.matted_fur.enabled then applyBuff( "matted_fur" ) end
            if azerite.masterful_instincts.enabled and buff.survival_instincts.up and buff.masterful_instincts.down then
                applyBuff( "masterful_instincts", buff.survival_instincts.remains + 30 )
            end
        end,
    },

    -- Talent: Consumes a Regrowth, Wild Growth, or Rejuvenation effect to instantly heal an ally for $s1.$?a383192[    Swiftmend heals the target for $383193o1 over $383193d.][]
    swiftmend = {
        id = 18562,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "nature",

        spend = 0.08,
        spendType = "mana",

        talent = "swiftmend",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        usable = function ()
            return IsSpellUsable( 18562 ) or buff.regrowth.up or buff.wild_growth.up or buff.rejuvenation.up, "requires a hot"
        end,

        handler = function ()
            unshift()
            if buff.regrowth.up then removeBuff( "regrowth" )
            elseif buff.wild_growth.up then removeBuff( "wild_growth" )
            elseif buff.rejuvenation.up then removeBuff( "rejuvenation" ) end
        end,
    },

    -- Talent: Swipe nearby enemies, inflicting Physical damage. Damage varies by shapeshift form.$?s137011[    |cFFFFFFFFAwards $s1 combo $lpoint:points;.|r][]
    swipe_bear = {
        id = 213771,
        known = 213764,
        suffix = "(Bear)",
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        talent = "swipe",
        startsCombat = true,

        handler = function ()
        end,

        form = "bear_form",

        copy = { "swipe", 213764 },
        bind = { "swipe_bear", "swipe_cat", "swipe" }
    },

    -- Talent: Strikes all nearby enemies, dealing $s1 Bleed damage and an additional $192090o1 Bleed damage over $192090d. When applied from Bear Form, this effect can stack up to $192090u times.    |cFFFFFFFFGenerates ${$m2/10} Rage.|r
    thrash_bear = {
        id = 77758,
        known = 106832,
        suffix = "(Bear)",
        cast = 0,
        cooldown = function () return ( buff.berserk_bear.up and talent.berserk_ravage.enabled and 0 or 6 ) * haste end,
        gcd = "spell",
        school = "physical",

        spend = -5,
        spendType = "rage",

        talent = "thrash",
        startsCombat = true,

        form = "bear_form",
        bind = "thrash",

        handler = function ()
            applyDebuff( "target", "thrash_bear", 15, debuff.thrash_bear.count + 1 )
            active_dot.thrash_bear = active_enemies

            if talent.ursocs_fury.enabled then applyBuff( "ursocs_fury" ) end
            if legendary.ursocs_fury_remembered.enabled then
                applyBuff( "ursocs_fury_remembered" )
            end

            if talent.earthwarden.enabled then addStack( "earthwarden", nil, 1 ) end
        end,
    },

    -- Talent: Shift into Cat Form and increase your movement speed by $s1%, reducing gradually over $d.
    tiger_dash = {
        id = 252216,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "physical",

        talent = "tiger_dash",
        startsCombat = false,

        handler = function ()
            if not buff.cat_form.up then shift( "cat_form" ) end
            applyBuff( "tiger_dash" )
        end,
    },

    -- Shapeshift into a travel form appropriate to your current location, increasing movement speed on land, in water, or in the air, and granting protection from Polymorph effects.    The act of shapeshifting frees you from movement impairing effects.$?a159456[    Land speed increased when used out of combat. This effect is disabled in battlegrounds and arenas.][]
    travel_form = {
        id = 783,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        startsCombat = false,

        handler = function ()
            applyBuff( "travel_form" )
        end,
    },

    -- Talent: Blasts targets within $61391a1 yards in front of you with a violent Typhoon, knocking them back and dazing them for $61391d. Usable in all shapeshift forms.
    typhoon = {
        id = 132469,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        talent = "typhoon",
        startsCombat = false,

        handler = function ()
            if target.distance < 15 then
                applyDebuff( "target", "typhoon" )
            end
        end,
    },

    -- Talent: Conjures a vortex of wind for $d at the destination, reducing the movement speed of all enemies within $A1 yards by $s1%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center.  Usable in all shapeshift forms.
    ursols_vortex = {
        id = 102793,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "nature",

        talent = "ursols_vortex",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "ursols_vortex" )
        end,
    },

    -- Talent: Bound backward away from your enemies.
    wild_charge = {
        id = function ()
            if buff.bear_form.up then return 16979
            elseif buff.cat_form.up then return 49376
            elseif buff.moonkin_form.up then return 102383 end
            return 102401
        end,
        known = 102401,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "wild_charge",
        startsCombat = false,

        usable = function () return target.exists and target.distance > 7, "target must be 8+ yards away" end,

        handler = function ()
            if buff.bear_form.up then target.distance = 5; applyDebuff( "target", "immobilized" )
            elseif buff.cat_form.up then target.distance = 5; applyDebuff( "target", "dazed" ) end
        end,

        copy = { 49376, 16979, 102401, 102383 }
    },

    -- Talent: Heals up to $s2 injured allies within $A1 yards of the target for $o1 over $d. Healing starts high and declines over the duration.$?s33891[    |C0033AA11Tree of Life: Affects $33891s3 additional $ltarget:targets;.|R][]
    wild_growth = {
        id = 48438,
        cast = 1.5,
        cooldown = 10,
        gcd = "spell",
        school = "nature",

        spend = 0.22,
        spendType = "mana",

        talent = "wild_growth",
        startsCombat = false,

        handler = function ()
            applyBuff( "wild_growth" )
        end,
    },
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "spectral_agility",

    package = "Guardian",
} )

spec:RegisterSetting( "maul_rage", 20, {
    name = "Excess Rage for |T132136:0|t Maul",
    desc = "If set above zero, the addon will recommend |T132136:0|t Maul only if you have at least this much excess Rage.",
    type = "range",
    min = 0,
    max = 60,
    step = 0.1,
    width = "full"
} )

spec:RegisterSetting( "mangle_more", false, {
    name = "Use |T132135:0|t Mangle More in Multi-Target",
    desc = "If checked, the default priority will recommend |T132135:0|t Mangle more often in |cFFFFD100multi-target|r scenarios.  This will generate roughly 15% more Rage and allow for more mitigation (or |T132136:0|t Maul) than otherwise, " ..
        "funnel slightly more damage into your primary target, but will |T134296:0|t Swipe less often, dealing less damage/threat to your secondary targets.",
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "ironfur_damage_threshold", 5, {
    name = "Required Damage % for |T1378702:0|t Ironfur",
    desc = "If set above zero, the addon will not recommend |T1378702:0|t Ironfur unless your incoming damage for the past 5 seconds is greater than this percentage of your maximum health.",
    type = "range",
    min = 0,
    max = 100,
    step = 0.1,
    width = "full"
} )

spec:RegisterSetting( "shift_for_convoke", false, {
    name = "|T3636839:0|t Powershift for Convoke the Spirits",
    desc = "If checked and you are a Night Fae, the addon will recommend swapping to your Feral/Balance Affinity specialization before using |T3636839:0|t Convoke the Spirits.  " ..
        "This is a DPS gain unless you die horribly.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "catweave_bear", false, {
    name = "|T132115:0|t Attempt Catweaving (Experimental)",
    desc = function()
        local affinity

        if state.talent.feral_affinity.enabled then
            affinity = "|cFF00FF00" .. ( GetSpellInfo( 202155 ) ) .. "|r"
        else
            affinity = "|cFFFF0000" .. ( GetSpellInfo( 202155 ) ) .. "|r"
        end

        return "If checked, the addon will use the experimental |cFFFFD100catweave|r priority included in the default priority pack.\n\nRequires " .. affinity .. "."
    end,
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "owlweave_bear", false, {
    name = "|T136036:0|t Attempt Owlweaving (Experimental)",
    desc = function()
        local affinity

        if state.talent.balance_affinity.enabled then
            affinity = "|cFF00FF00" .. ( GetSpellInfo( 197488 ) ) .. "|r"
        else
            affinity = "|cFFFF0000" .. ( GetSpellInfo( 197488 ) ) .. "|r"
        end

        return "If checked, the addon will use the experimental |cFFFFD100owlweave|r priority included in the default priority pack.\n\nRequires " .. affinity .. "."
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterPack( "Guardian", 20221025, [[Hekili:TZX2okoY1Vf0k5g00IgBGzMEvdsjBKsMrrZkfwPnpbymfGtBSj2LB2EfYk)g53lFj5CkFRSRQCzGU7zVjTAhg7Qo15(T64zU58Fy(S12uY8VynWYYCG14(wdnTmTMpJ(8bY8zhSDE0El8dF79W))VgBhU212hFXZEb2Rraefeh6aVChLEi6BV7UTU0DXR67eS)Ui39XE2u3aFNq7nu8V7C38zRID9OFYF(kjN(GrJUF(m7y6UGW5ZM5U)7ai7UEnjD5KiNs0iz5Fjm2DDYNTgNS87DObRiHjlrGLSSR5kYhnxB3l5ZjF(t(UuxBVKLZ2zVo4ONT)6OKLU7pees7pFMNBenIXliBSJ9OWp)cJ3q8Tx5rwp)ppFMtOlLe6ApFwNKLRI3SP)Hqas9JpayRdsIaN4XypVfRSJ2nNcevniKVQ)van2FlXnmCbqoux)NJw4y7510zKS0izj8qNGNai6t7d)bD3ZH5cgLWeWJHkWdAOR)JeQ5LCU5ppdg9PM9DJ67y7SJSiyZcBN)DSBiz9cAiXokoKeX2qx2EyhqXkS)jc35u9DrhdcxR8ThbPi7L9aoVxaLJIaQEuZuT1lcvB9liQ2cP6XnP1kLC6M)FuBp4X93rSdPi1qbI6OR36(zGJTAgUiUeg(KdU1OnjWvOhj2prwScwDYYtNYFbWI5FrVkKzPeOx6EsXn27aJ7is4JS9Xwc(E2BC9DSd9z(zwSnZ3aIFXHrbovrUokWpdUxjIH9yS7CvOdbS)ey3VVg7gDpf6EiDzFx6j46Vnzz6wtwIEAswc8mWx0ksYYq0jM7MBps(F)N)Bi8a)ak(g2M2t8iK13c)W2FRh5o6UqW1camCHi0CWxgc(NbyeHBZl4yYYrdGN(ZaNcwPpi244oz7fCb6dRjiKD2a(qUbFSlcsB6MGW9zBL4tc3(Ck0TxbQpG31Xz78Vfq)XS3ae3tKs(tyS)I0FVaPxETqQ7EagtNKSC4agtxQWaETjNYPtqGhIYqif)NcEKW07Io4cqnQFizVTRpGfpKURcjDl0mqGwQwxr)k9vLkHVqqZOkbLkrtxtbHmnzzkVPyzPYFjRyDaT)(Ga)nGRbUxdCIToG47DW66pwGmaU9cuiN7JjxkpfLUcRwU1E1TD)GCBeuGVinMuUqfnu(qtgkFFQ9wRmuqL1MmvMrTdbxVOjbYbq1teD1Ao0)YuF7Y5XRMBdE1XxcThEfIOCQmpsahBphnq2(hBIT)PnCmZuV)eg)HgGhfZulJNDKXL8Vbfjqaey5bmxfSd6U8t8wUvVZgDwSYgs1YHC3gsiM9L9MnUqMypxECWw(XDGI0tyIBfNjVKdbw0rxQZUCuRekPEQsXfuDXLcWBhbPh0Q4r0Hgtr)3Kc371lCV53II2IquxTOnlLhzHvks6r0P9zffsv(gflRMpZmGJYxZbksHvGq5aacDyZWddYbvJfZ0QS(6Oluq(cYS6YJUuIYc7uwbsIjKReE8VOOgN8xkraXFomUdJp1QY8WvkIafpTzcrh7vdhsvPB5X8LCuGdhxFYc71Kd0kcXU56JuxNhzbnnWFVh4tblw7sybYnT4J)hs2afXSdHrtRovzpnlWfGf)ExSYNhsw(Ea)E2Xd2Jn4odKcFrAPzL0qtmC7WhJa8U5QCkRMP9fMIe7zurhNtFHY56XZ9o7YJpVkl5kije8R4hehTaex()8ZYQmPIE95wbKXRnlTzBxj5pwrI3CPTVIOTgnHsQIl7azPL1uhzod0xbYiR7i1ZDOPUJCgCK2HbwsJULg)AlO15L7geCXbb2SdxHOsjs2WAqax3LEkGpgAFic3euPGdnmaYYcCeUaQLh0yCT9kbV2vIhsDx(PhcqFBXD6e45bab)BBIPiVHZyv9AqaRYLFB6A4L0DqtnnktF7b12LSwP529vQlzPw1xCh((QI7YSCnRh8Rjt3ltE1k78xlA(kLxFvXDP(5uhjwkXuVAYQT1XAKMfH1FynwwVknvhd9StjqB8AZ6H4QeWMH(1sAPOJUsLY94Z8Mv9m7uQhg7L7uQfX2QE0kXt6QApTa5bHfyNRjFHnK9hcoscxSkWFD1kA(IL6AqYQcnG23ET9bws6rhTd3VyT9E7TK(81d0jVdCkwlwYLN72Duo7ijqgkMXReUSE)Ryr890CyH5VAKfcg78iR4IHmuq9klnjswowZAlqvobr1vY4X1JnxYJJcI9w5c(boehrJHkEiHXSoXiPeSxMU)wEDlk7b8WKx2UHN)QT2EitYPagL93ot(vWoEkaV(xGFef4HMzL1966dSoKjTWDdh)R(gm62e7A6adfSPPd6v5m2VNaykfsgYSueVXdQULDZ08RDRxWkmFqw4wRr8gG4DTKN4zKhHCatlTQDyJ1M(k6OOEyMchzHGQrCyD39e2bsdcO7waXVw44zFCr2tRfOldcS84LvoVL6al66jHc1PmeqXBReRJ7EoK0Eee7uwSvP6epkxPNh5(I4v9Q4bcxq9gFGMEJuWQuhWQfkaTXavbYKt0rhDpKfchBVuJr1K41ipfnjhuHh58Tvv3kNTXsIPwJsuSdETGAVI33Uz2nCPeN4Sz2BhNoseQB7Ns6IHhp564IztKkCrWXtykuikarNIwolbofEgfq2gdTlvejJxmHpaBkxp9QJFO4(7uZcLURpQHXBuqUO79Ic2da7lALgSZFDJBHxx3vxQRDgVqDiybnFq1qU1ochvv9Eigc7e6(ZvATQcxa49Lk3oF4y(Ogv80ujAXq1fhOZ1PewULCpGd)apYW5bOcUG3xs(f2(gEJbC3fDjoEH3wGuyL)qgNOzVVId0vOD6vXOUJ1xn3qdvRoDcjvSPOsbAtTdg1TrYSVqGV873h0SgnwKNOoQpdKUh6x)6dCc2VkyXHaivRSitCgOWgqO(rEDvTxKJqFm5lUU(HLw6m3ulmEaxQGKWGuxYyJezfxQo4yvyJEw54pr7cjmEUqJi)JsYEXljtOpSNBjzCk5dh)Ix8sk0Fach8sulI5qrh5G9VGF8dHeud1wZCS2v3vtBKEJFPkcdK7svBBhUOtq617Er(F14EvTJ9lM7WII0SR7UYAWzLs74UCz1UUBHg(lR(8lHwmMNXxHjt4TppJwheJYnwp)kJJOlj1xU67nvKBBJjHefN3vSIer48FgxaLk94Py8RQlLa5euAqeUi2hSWG7Hi8ZGir(qCkqM(J)P)Xx(0x(RFBYYKL)Wos(3xaBoLswEt23wWn4yvKEZbOPj6aXoMgS3MnHwo7GsDir9t(8Fh4OGJfaAFhOarczV(M875WS))8M0XJ6gURQcFwxZFQxX2hPy7ws2Uf)2t(SgQbDrDEKY4ZNuS4ifvBVbsHF7V)8pDZwSDTmY0T)HR70vT9wE6F86o97VUt3uLsylf8MxSKp5ZFIPZI76dvhTyuTem1pqCWe9hXIAVXfDp8nFtYsHVVi8H6(gJW1043zeUOuCiQFrkAVBYD5oIV1DZKUsY5yIzpdmtJPdhiha8zlXasNlbkcU(rqPnKJuqXsQ5IjNISFsPLkPj1t(wkt7a3J28IoDsBor3kjtNjM3wpNMkpI)ORdxoHpGVLFOyi(wLe5xxCezbeqB)T4CCmr1yCicdJocxUPmOI3w9K8HlOnqXOtPXBZ3ZUrMGR29RBu7P53SE9NNDN690I2wNhARB8aEfq70BGNHMc4v3UD1zHzOmBUEgYmVoDsY913ZOMz0PtD7YEsTlJ60P69tw6frbhTmFmgDKD29a2b4B83zFou8Qa1gy7uR5CohZnl6pCYWbgs9xcQjTz4ZFa9S2TfYpeqgIsF8XOIXvcHl)gBnKDv2tNaLa8Ub9hxGACfUK1GLPwLVvMLs(YUFqMU4Vi(IJ0QHu8XxWRH0TReBmuYFDIndPF(jPCRFh9Hc9RmzYVd((E0krY7MunjI(VThEpvADRQiL6EArpwxd5Y8h)71tYTtM8V87Eqy9xz25zqj356TvU0YjMCatwVCa2zNS(XBW9nGm10cD7Y1DL6VTNrAWW8RP8H3lYiY(UoquqpBO248XQqaK1TmP0tNABEGzMU1sdShsUTpf4wN1zpb6uI(itrPTjDz8AWteWsopBP1Qjjb3xb8qHSra9uxNtBrkPNu7ohl(ZrhjDMNdZXI6VccnBu333GMThQ87xqZgBQ8vLLRQxwwR4VV6LSE6u7lh9ncLAh3uwP0F1RK(C4MVrOKa3SScFbCREcGLv1yns5lFyI14x8icsYaPmDtM3Bg6ioV8GeOozPpsW1aRYbBTeuxyBkeGn)CXi8YQJxqwNu1nGcgDsHIUPZWqkS4NkJtN0mrgth2t6A4NdJhgAOD(lEyCdRjdzezDNzpw5BAXz2haSXws7eWWRU)gPpw(aSJz39M3x4lVBjIsijtN(BQXv2GIlR4IoAg48mFTLJAU6sx0uQIcbmCekEtHt3S(mjCYCYfzKgx5pPwNctk6ddpDQADqtNms4yyZZtrvqxUgU(tchS40kNeIaHT2TkaahkDLi6sPmimwVYEjlm)2gYECo)2S)yXZsuPkhzfWkgSvnp2GVI68CylD0o91soE0QR0wPkZQo(pziJBGgIpC)ajKxXB)OeI3q70sx0LZSPKwKDXRSkW1MAkM7s(8olt1wQ28uRMo0l2UTgZq8qkhCz(2PKN4Z7UWwKK54rAxJtFfx7MLES8xFB72bobTfg6cx73Rjjj9q4ZjIj1Lm2BnrgYMG4tNYg9XrJLVx3dfBT6KcBWpCTtNykNNlMmS01vDQEtZqNh6JYVzGXdKUF2S8wFBpmron9hPpkn9rEXXzMczX4Z(1iXSIdxUMr(03wXzuME5RGLBJoJkp226mIBhYmLkxzEnKVXKe3X22aixxIFMsp7Szem3vLK5ju(2kUsqEo5RUYrT)1Ys6rxFwHA)oL)L(tNp)))]] )