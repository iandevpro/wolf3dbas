' The state table - statetype variables of WL_AGENT.C / WL_ACT2.C
'
' C has one statetype variable per state (s_player, s_grdstand...), with the next state and
' the think / action routines as pointers. Here the states are rows of states(), named
' by constants (index 0 = NULL), and the routines are ids dispatched by CallStateRoutine.
' Generated from the C initializers (gen_states.py); InitStates in WL_STATE.BM fills the table.
$If INCLUDE_WL_STATE_BI = UNDEFINED Then
    $Let INCLUDE_WL_STATE_BI = 1

    Const MAXSTATES = 441
    Dim Shared states(0 To MAXSTATES) As statetype

    '
    ' routine ids (think / action), 0 = NULL
    '
    Const RT_NONE = 0
    Const RT_T_PLAYER = 1
    Const RT_T_ATTACK = 2
    Const RT_T_PROJECTILE = 3
    Const RT_A_SMOKE = 4
    Const RT_T_STAND = 5
    Const RT_T_PATH = 6
    Const RT_T_SHOOT = 7
    Const RT_T_CHASE = 8
    Const RT_A_DEATHSCREAM = 9
    Const RT_T_GHOSTS = 10
    Const RT_T_BITE = 11
    Const RT_T_DOGCHASE = 12
    Const RT_T_USHOOT = 13
    Const RT_T_WILL = 14
    Const RT_T_LAUNCH = 15
    Const RT_A_SLURPIE = 16
    Const RT_A_VICTORY = 17
    Const RT_A_STARTATTACK = 18
    Const RT_A_RELAUNCH = 19
    Const RT_A_BREATHING = 20
    Const RT_A_DORMANT = 21
    Const RT_T_SCHABB = 22
    Const RT_A_STARTDEATHCAM = 23
    Const RT_T_SCHABBTHROW = 24
    Const RT_T_GIFT = 25
    Const RT_T_GIFTTHROW = 26
    Const RT_T_FAT = 27
    Const RT_T_FAKE = 28
    Const RT_T_FAKEFIRE = 29
    Const RT_A_MECHASOUND = 30
    Const RT_A_HITLERMORPH = 31
    Const RT_T_BJRUN = 32
    Const RT_T_BJJUMP = 33
    Const RT_T_BJYELL = 34
    Const RT_T_BJDONE = 35

    '
    ' state ids, 0 = NULL (the Spear-only ones exist as ids in WL6 too)
    '
    Const s_player = 1
    Const s_attack = 2
    Const s_rocket = 3
    Const s_smoke1 = 4
    Const s_smoke2 = 5
    Const s_smoke3 = 6
    Const s_smoke4 = 7
    Const s_boom1 = 8
    Const s_boom2 = 9
    Const s_boom3 = 10
    Const s_hrocket = 11
    Const s_hsmoke1 = 12
    Const s_hsmoke2 = 13
    Const s_hsmoke3 = 14
    Const s_hsmoke4 = 15
    Const s_hboom1 = 16
    Const s_hboom2 = 17
    Const s_hboom3 = 18
    Const s_grdstand = 19
    Const s_grdpath1 = 20
    Const s_grdpath1s = 21
    Const s_grdpath2 = 22
    Const s_grdpath3 = 23
    Const s_grdpath3s = 24
    Const s_grdpath4 = 25
    Const s_grdpain = 26
    Const s_grdpain1 = 27
    Const s_grdshoot1 = 28
    Const s_grdshoot2 = 29
    Const s_grdshoot3 = 30
    Const s_grdchase1 = 31
    Const s_grdchase1s = 32
    Const s_grdchase2 = 33
    Const s_grdchase3 = 34
    Const s_grdchase3s = 35
    Const s_grdchase4 = 36
    Const s_grddie1 = 37
    Const s_grddie2 = 38
    Const s_grddie3 = 39
    Const s_grddie4 = 40
    Const s_blinkychase1 = 41
    Const s_blinkychase2 = 42
    Const s_inkychase1 = 43
    Const s_inkychase2 = 44
    Const s_pinkychase1 = 45
    Const s_pinkychase2 = 46
    Const s_clydechase1 = 47
    Const s_clydechase2 = 48
    Const s_dogpath1 = 49
    Const s_dogpath1s = 50
    Const s_dogpath2 = 51
    Const s_dogpath3 = 52
    Const s_dogpath3s = 53
    Const s_dogpath4 = 54
    Const s_dogjump1 = 55
    Const s_dogjump2 = 56
    Const s_dogjump3 = 57
    Const s_dogjump4 = 58
    Const s_dogjump5 = 59
    Const s_dogchase1 = 60
    Const s_dogchase1s = 61
    Const s_dogchase2 = 62
    Const s_dogchase3 = 63
    Const s_dogchase3s = 64
    Const s_dogchase4 = 65
    Const s_dogdie1 = 66
    Const s_dogdie2 = 67
    Const s_dogdie3 = 68
    Const s_dogdead = 69
    Const s_ofcstand = 70
    Const s_ofcpath1 = 71
    Const s_ofcpath1s = 72
    Const s_ofcpath2 = 73
    Const s_ofcpath3 = 74
    Const s_ofcpath3s = 75
    Const s_ofcpath4 = 76
    Const s_ofcpain = 77
    Const s_ofcpain1 = 78
    Const s_ofcshoot1 = 79
    Const s_ofcshoot2 = 80
    Const s_ofcshoot3 = 81
    Const s_ofcchase1 = 82
    Const s_ofcchase1s = 83
    Const s_ofcchase2 = 84
    Const s_ofcchase3 = 85
    Const s_ofcchase3s = 86
    Const s_ofcchase4 = 87
    Const s_ofcdie1 = 88
    Const s_ofcdie2 = 89
    Const s_ofcdie3 = 90
    Const s_ofcdie4 = 91
    Const s_ofcdie5 = 92
    Const s_mutstand = 93
    Const s_mutpath1 = 94
    Const s_mutpath1s = 95
    Const s_mutpath2 = 96
    Const s_mutpath3 = 97
    Const s_mutpath3s = 98
    Const s_mutpath4 = 99
    Const s_mutpain = 100
    Const s_mutpain1 = 101
    Const s_mutshoot1 = 102
    Const s_mutshoot2 = 103
    Const s_mutshoot3 = 104
    Const s_mutshoot4 = 105
    Const s_mutchase1 = 106
    Const s_mutchase1s = 107
    Const s_mutchase2 = 108
    Const s_mutchase3 = 109
    Const s_mutchase3s = 110
    Const s_mutchase4 = 111
    Const s_mutdie1 = 112
    Const s_mutdie2 = 113
    Const s_mutdie3 = 114
    Const s_mutdie4 = 115
    Const s_mutdie5 = 116
    Const s_ssstand = 117
    Const s_sspath1 = 118
    Const s_sspath1s = 119
    Const s_sspath2 = 120
    Const s_sspath3 = 121
    Const s_sspath3s = 122
    Const s_sspath4 = 123
    Const s_sspain = 124
    Const s_sspain1 = 125
    Const s_ssshoot1 = 126
    Const s_ssshoot2 = 127
    Const s_ssshoot3 = 128
    Const s_ssshoot4 = 129
    Const s_ssshoot5 = 130
    Const s_ssshoot6 = 131
    Const s_ssshoot7 = 132
    Const s_ssshoot8 = 133
    Const s_ssshoot9 = 134
    Const s_sschase1 = 135
    Const s_sschase1s = 136
    Const s_sschase2 = 137
    Const s_sschase3 = 138
    Const s_sschase3s = 139
    Const s_sschase4 = 140
    Const s_ssdie1 = 141
    Const s_ssdie2 = 142
    Const s_ssdie3 = 143
    Const s_ssdie4 = 144
    Const s_bossstand = 145
    Const s_bosschase1 = 146
    Const s_bosschase1s = 147
    Const s_bosschase2 = 148
    Const s_bosschase3 = 149
    Const s_bosschase3s = 150
    Const s_bosschase4 = 151
    Const s_bossdie1 = 152
    Const s_bossdie2 = 153
    Const s_bossdie3 = 154
    Const s_bossdie4 = 155
    Const s_bossshoot1 = 156
    Const s_bossshoot2 = 157
    Const s_bossshoot3 = 158
    Const s_bossshoot4 = 159
    Const s_bossshoot5 = 160
    Const s_bossshoot6 = 161
    Const s_bossshoot7 = 162
    Const s_bossshoot8 = 163
    Const s_gretelstand = 164
    Const s_gretelchase1 = 165
    Const s_gretelchase1s = 166
    Const s_gretelchase2 = 167
    Const s_gretelchase3 = 168
    Const s_gretelchase3s = 169
    Const s_gretelchase4 = 170
    Const s_greteldie1 = 171
    Const s_greteldie2 = 172
    Const s_greteldie3 = 173
    Const s_greteldie4 = 174
    Const s_gretelshoot1 = 175
    Const s_gretelshoot2 = 176
    Const s_gretelshoot3 = 177
    Const s_gretelshoot4 = 178
    Const s_gretelshoot5 = 179
    Const s_gretelshoot6 = 180
    Const s_gretelshoot7 = 181
    Const s_gretelshoot8 = 182
    Const s_transstand = 183
    Const s_transchase1 = 184
    Const s_transchase1s = 185
    Const s_transchase2 = 186
    Const s_transchase3 = 187
    Const s_transchase3s = 188
    Const s_transchase4 = 189
    Const s_transdie0 = 190
    Const s_transdie01 = 191
    Const s_transdie1 = 192
    Const s_transdie2 = 193
    Const s_transdie3 = 194
    Const s_transdie4 = 195
    Const s_transshoot1 = 196
    Const s_transshoot2 = 197
    Const s_transshoot3 = 198
    Const s_transshoot4 = 199
    Const s_transshoot5 = 200
    Const s_transshoot6 = 201
    Const s_transshoot7 = 202
    Const s_transshoot8 = 203
    Const s_uberstand = 204
    Const s_uberchase1 = 205
    Const s_uberchase1s = 206
    Const s_uberchase2 = 207
    Const s_uberchase3 = 208
    Const s_uberchase3s = 209
    Const s_uberchase4 = 210
    Const s_uberdie0 = 211
    Const s_uberdie01 = 212
    Const s_uberdie1 = 213
    Const s_uberdie2 = 214
    Const s_uberdie3 = 215
    Const s_uberdie4 = 216
    Const s_uberdie5 = 217
    Const s_ubershoot1 = 218
    Const s_ubershoot2 = 219
    Const s_ubershoot3 = 220
    Const s_ubershoot4 = 221
    Const s_ubershoot5 = 222
    Const s_ubershoot6 = 223
    Const s_ubershoot7 = 224
    Const s_willstand = 225
    Const s_willchase1 = 226
    Const s_willchase1s = 227
    Const s_willchase2 = 228
    Const s_willchase3 = 229
    Const s_willchase3s = 230
    Const s_willchase4 = 231
    Const s_willdeathcam = 232
    Const s_willdie1 = 233
    Const s_willdie2 = 234
    Const s_willdie3 = 235
    Const s_willdie4 = 236
    Const s_willdie5 = 237
    Const s_willdie6 = 238
    Const s_willshoot1 = 239
    Const s_willshoot2 = 240
    Const s_willshoot3 = 241
    Const s_willshoot4 = 242
    Const s_willshoot5 = 243
    Const s_willshoot6 = 244
    Const s_deathstand = 245
    Const s_deathchase1 = 246
    Const s_deathchase1s = 247
    Const s_deathchase2 = 248
    Const s_deathchase3 = 249
    Const s_deathchase3s = 250
    Const s_deathchase4 = 251
    Const s_deathdeathcam = 252
    Const s_deathdie1 = 253
    Const s_deathdie2 = 254
    Const s_deathdie3 = 255
    Const s_deathdie4 = 256
    Const s_deathdie5 = 257
    Const s_deathdie6 = 258
    Const s_deathdie7 = 259
    Const s_deathdie8 = 260
    Const s_deathdie9 = 261
    Const s_deathshoot1 = 262
    Const s_deathshoot2 = 263
    Const s_deathshoot3 = 264
    Const s_deathshoot4 = 265
    Const s_deathshoot5 = 266
    Const s_angelstand = 267
    Const s_angelchase1 = 268
    Const s_angelchase1s = 269
    Const s_angelchase2 = 270
    Const s_angelchase3 = 271
    Const s_angelchase3s = 272
    Const s_angelchase4 = 273
    Const s_angeldie1 = 274
    Const s_angeldie11 = 275
    Const s_angeldie2 = 276
    Const s_angeldie3 = 277
    Const s_angeldie4 = 278
    Const s_angeldie5 = 279
    Const s_angeldie6 = 280
    Const s_angeldie7 = 281
    Const s_angeldie8 = 282
    Const s_angeldie9 = 283
    Const s_angelshoot1 = 284
    Const s_angelshoot2 = 285
    Const s_angelshoot3 = 286
    Const s_angeltired = 287
    Const s_angeltired2 = 288
    Const s_angeltired3 = 289
    Const s_angeltired4 = 290
    Const s_angeltired5 = 291
    Const s_angeltired6 = 292
    Const s_angeltired7 = 293
    Const s_spark1 = 294
    Const s_spark2 = 295
    Const s_spark3 = 296
    Const s_spark4 = 297
    Const s_spectrewait1 = 298
    Const s_spectrewait2 = 299
    Const s_spectrewait3 = 300
    Const s_spectrewait4 = 301
    Const s_spectrechase1 = 302
    Const s_spectrechase2 = 303
    Const s_spectrechase3 = 304
    Const s_spectrechase4 = 305
    Const s_spectredie1 = 306
    Const s_spectredie2 = 307
    Const s_spectredie3 = 308
    Const s_spectredie4 = 309
    Const s_spectrewake = 310
    Const s_schabbstand = 311
    Const s_schabbchase1 = 312
    Const s_schabbchase1s = 313
    Const s_schabbchase2 = 314
    Const s_schabbchase3 = 315
    Const s_schabbchase3s = 316
    Const s_schabbchase4 = 317
    Const s_schabbdeathcam = 318
    Const s_schabbdie1 = 319
    Const s_schabbdie2 = 320
    Const s_schabbdie3 = 321
    Const s_schabbdie4 = 322
    Const s_schabbdie5 = 323
    Const s_schabbdie6 = 324
    Const s_schabbshoot1 = 325
    Const s_schabbshoot2 = 326
    Const s_needle1 = 327
    Const s_needle2 = 328
    Const s_needle3 = 329
    Const s_needle4 = 330
    Const s_giftstand = 331
    Const s_giftchase1 = 332
    Const s_giftchase1s = 333
    Const s_giftchase2 = 334
    Const s_giftchase3 = 335
    Const s_giftchase3s = 336
    Const s_giftchase4 = 337
    Const s_giftdeathcam = 338
    Const s_giftdie1 = 339
    Const s_giftdie2 = 340
    Const s_giftdie3 = 341
    Const s_giftdie4 = 342
    Const s_giftdie5 = 343
    Const s_giftdie6 = 344
    Const s_giftshoot1 = 345
    Const s_giftshoot2 = 346
    Const s_fatstand = 347
    Const s_fatchase1 = 348
    Const s_fatchase1s = 349
    Const s_fatchase2 = 350
    Const s_fatchase3 = 351
    Const s_fatchase3s = 352
    Const s_fatchase4 = 353
    Const s_fatdeathcam = 354
    Const s_fatdie1 = 355
    Const s_fatdie2 = 356
    Const s_fatdie3 = 357
    Const s_fatdie4 = 358
    Const s_fatdie5 = 359
    Const s_fatdie6 = 360
    Const s_fatshoot1 = 361
    Const s_fatshoot2 = 362
    Const s_fatshoot3 = 363
    Const s_fatshoot4 = 364
    Const s_fatshoot5 = 365
    Const s_fatshoot6 = 366
    Const s_fakestand = 367
    Const s_fakechase1 = 368
    Const s_fakechase1s = 369
    Const s_fakechase2 = 370
    Const s_fakechase3 = 371
    Const s_fakechase3s = 372
    Const s_fakechase4 = 373
    Const s_fakedie1 = 374
    Const s_fakedie2 = 375
    Const s_fakedie3 = 376
    Const s_fakedie4 = 377
    Const s_fakedie5 = 378
    Const s_fakedie6 = 379
    Const s_fakeshoot1 = 380
    Const s_fakeshoot2 = 381
    Const s_fakeshoot3 = 382
    Const s_fakeshoot4 = 383
    Const s_fakeshoot5 = 384
    Const s_fakeshoot6 = 385
    Const s_fakeshoot7 = 386
    Const s_fakeshoot8 = 387
    Const s_fakeshoot9 = 388
    Const s_fire1 = 389
    Const s_fire2 = 390
    Const s_mechastand = 391
    Const s_mechachase1 = 392
    Const s_mechachase1s = 393
    Const s_mechachase2 = 394
    Const s_mechachase3 = 395
    Const s_mechachase3s = 396
    Const s_mechachase4 = 397
    Const s_mechadie1 = 398
    Const s_mechadie2 = 399
    Const s_mechadie3 = 400
    Const s_mechadie4 = 401
    Const s_mechashoot1 = 402
    Const s_mechashoot2 = 403
    Const s_mechashoot3 = 404
    Const s_mechashoot4 = 405
    Const s_mechashoot5 = 406
    Const s_mechashoot6 = 407
    Const s_hitlerchase1 = 408
    Const s_hitlerchase1s = 409
    Const s_hitlerchase2 = 410
    Const s_hitlerchase3 = 411
    Const s_hitlerchase3s = 412
    Const s_hitlerchase4 = 413
    Const s_hitlerdeathcam = 414
    Const s_hitlerdie1 = 415
    Const s_hitlerdie2 = 416
    Const s_hitlerdie3 = 417
    Const s_hitlerdie4 = 418
    Const s_hitlerdie5 = 419
    Const s_hitlerdie6 = 420
    Const s_hitlerdie7 = 421
    Const s_hitlerdie8 = 422
    Const s_hitlerdie9 = 423
    Const s_hitlerdie10 = 424
    Const s_hitlershoot1 = 425
    Const s_hitlershoot2 = 426
    Const s_hitlershoot3 = 427
    Const s_hitlershoot4 = 428
    Const s_hitlershoot5 = 429
    Const s_hitlershoot6 = 430
    Const s_bjrun1 = 431
    Const s_bjrun1s = 432
    Const s_bjrun2 = 433
    Const s_bjrun3 = 434
    Const s_bjrun3s = 435
    Const s_bjrun4 = 436
    Const s_bjjump1 = 437
    Const s_bjjump2 = 438
    Const s_bjjump3 = 439
    Const s_bjjump4 = 440
    Const s_deathcam = 441

    ' ---- hand-written tables, kept as they are by tools/gen_states.py ----

    '
    ' WL_STATE.C
    '
    ' dirtype opposite[9] = {west,southwest,south,southeast,east,northeast,north,northwest,nodir}
    Dim Shared opposite(0 To 8) As Integer
    opposite(0) = dt_west: opposite(1) = dt_southwest: opposite(2) = dt_south: opposite(3) = dt_southeast
    opposite(4) = dt_east: opposite(5) = dt_northeast: opposite(6) = dt_north: opposite(7) = dt_northwest
    opposite(8) = dt_nodir

    ' dirtype diagonal[9][9]: the diagonal between two cardinal directions, nodir otherwise
    Dim Shared diagonal(0 To 8, 0 To 8) As Integer
    Dim diagi As Integer, diagj As Integer
    For diagi = 0 To 8
        For diagj = 0 To 8
            diagonal(diagi, diagj) = dt_nodir
        Next diagj
    Next diagi
    diagonal(dt_east, dt_north) = dt_northeast: diagonal(dt_east, dt_south) = dt_southeast
    diagonal(dt_north, dt_east) = dt_northeast: diagonal(dt_north, dt_west) = dt_northwest
    diagonal(dt_west, dt_north) = dt_northwest: diagonal(dt_west, dt_south) = dt_southwest
    diagonal(dt_south, dt_east) = dt_southeast: diagonal(dt_south, dt_west) = dt_southwest

    '
    ' WL_ACT2.C
    '
    Const SPDPATROL = 512 ' WL_DEF.H
    Const SPDDOG = 1500

    Const PROJECTILESIZE = &HC000&

    Const BJRUNSPEED = 2048
    Const BJJUMPSPEED = 680

    ' int starthitpoints[4][NUMENEMIES]: per difficulty, guards, officer, SS, dogs, Hans, Schabbs,
    ' fake hitler, mecha hitler, mutants, 4 ghosts, Gretel, Gift, Fat, spectre, angel, trans,
    ' uber, will, death
    Dim Shared starthitpoints(0 To 3, 0 To 21) As Integer
    Dim hpsrc As String, hpi As Integer, hpj As Integer, hpp As Integer
    hpsrc = "25 50 100 1 850 850 200 800 45 25 25 25 25 850 850 850 5 1450 850 1050 950 1250 "
    hpsrc = hpsrc + "25 50 100 1 950 950 300 950 55 25 25 25 25 950 950 950 10 1550 950 1150 1050 1350 "
    hpsrc = hpsrc + "25 50 100 1 1050 1550 400 1050 55 25 25 25 25 1050 1050 1050 15 1650 1050 1250 1150 1450 "
    hpsrc = hpsrc + "25 50 100 1 1200 2400 500 1200 65 25 25 25 25 1200 1200 1200 25 2000 1200 1400 1300 1600 "
    hpp = 1
    For hpi = 0 To 3
        For hpj = 0 To 21
            starthitpoints(hpi, hpj) = Val(Mid$(hpsrc, hpp, InStr(hpp, hpsrc, " ") - hpp)) ' (Val skips spaces)
            hpp = InStr(hpp, hpsrc, " ") + 1
        Next hpj
    Next hpi

    ' A_DeathScream: int sounds[9] (only 8 set) of the guards
    Dim Shared deathscreams(0 To 8) As Integer
    deathscreams(0) = DEATHSCREAM1SND: deathscreams(1) = DEATHSCREAM2SND: deathscreams(2) = DEATHSCREAM3SND
    deathscreams(3) = DEATHSCREAM4SND: deathscreams(4) = DEATHSCREAM5SND: deathscreams(5) = DEATHSCREAM7SND
    deathscreams(6) = DEATHSCREAM8SND: deathscreams(7) = DEATHSCREAM9SND

    '
    ' WL_AGENT.C: struct atkinf {char tics,attack,frame;} attackinfo[4][14], attack is 1 for gun,
    ' 2 for knife (the rest of each row is 0)
    '
    Type atkinf
        tics As Integer
        attack As Integer
        frame As Integer
    End Type
    Dim Shared attackinfo(0 To 3, 0 To 13) As atkinf
    Dim atki As Integer, atkj As Integer, atksrc As String
    ' {6,0,1},{6,2,2},{6,0,3},{6,-1,4} / {6,0,1},{6,1,2},{6,0,3},{6,-1,4} /
    ' {6,0,1},{6,1,2},{6,3,3},{6,-1,4} / {6,0,1},{6,1,2},{6,4,3},{6,-1,4}
    atksrc = "0203-1" + "0103-1" + "0133-1" + "0143-1" ' the attack of frames 0-3 (frame = index+1)
    For atki = 0 To 3
        For atkj = 0 To 3
            attackinfo(atki, atkj).tics = 6
            attackinfo(atki, atkj).frame = atkj + 1
        Next atkj
        attackinfo(atki, 0).attack = 0
        attackinfo(atki, 1).attack = Val(Mid$(atksrc, atki * 6 + 2, 1))
        attackinfo(atki, 2).attack = Val(Mid$(atksrc, atki * 6 + 3, 1))
        attackinfo(atki, 3).attack = -1
    Next atki

$End If
