CLASS zcl_alloc_cfg_check DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Check wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_check | <p class="shorttext synchronized">Ready to use check</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_check) TYPE REF TO zcl_alloc_cfg_check.

    "! <p class="shorttext synchronized">Wire up the check</p>
    "!
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">What is wrong with a plant's Customizing</p>
    "!
    "! Every table this solution reads is maintained by a person, and almost
    "! everything that can be typed wrongly in one of them is invisible until
    "! a night behaves oddly: a quota whose period runs backwards never binds,
    "! a substitute pointing at a material that was deleted offers stock that
    "! cannot exist, a class named in `ZSTOCK_ALLOC_EXT` that nobody
    "! transported fails the whole plant on the first material.
    "!
    "! This is the check somebody runs after transporting Customizing, and
    "! again when a night is strange. It changes nothing.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

    "! <p class="shorttext synchronized">The same, for every plant the user may see</p>
    "!
    "! What somebody wants after a transport: not "is plant 1000 right" but
    "! "did any of this land wrongly anywhere". A plant the user may not see is
    "! left out rather than refused, because a check that stops at the first
    "! plant somebody is not responsible for cannot be run by anybody.
    "!
    "! @parameter rt_line | <p class="shorttext synchronized">Lines to display</p>
    METHODS run_everywhere
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

  PRIVATE SECTION.

    "! Reading Customizing, changing none of it.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    CONSTANTS c_max_percent TYPE i VALUE 100.
    CONSTANTS c_no_end      TYPE d VALUE '00000000'.

    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS plant_lines
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS settings_lines
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS quota_lines
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS promise_lines
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS substitute_lines
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS hold_lines
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS priority_lines
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS extension_lines
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS is_a_material
      IMPORTING
        iv_matnr        TYPE mard-matnr
      RETURNING
        VALUE(rv_there) TYPE abap_bool.

    METHODS is_in_the_plant
      IMPORTING
        iv_matnr        TYPE mard-matnr
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rv_there) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_cfg_check IMPLEMENTATION.

  METHOD create_default.

    ro_check = NEW zcl_alloc_cfg_check( NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.
    mo_authority = io_authority.
  ENDMETHOD.

  METHOD run.

    mo_authority->check_plant( iv_werks ).

    APPEND |Plant { iv_werks }, what is wrong with the Customizing| TO rt_line.

    APPEND LINES OF plant_lines( iv_werks ) TO rt_line.
    APPEND LINES OF settings_lines( iv_werks ) TO rt_line.
    APPEND LINES OF quota_lines( iv_werks ) TO rt_line.
    APPEND LINES OF promise_lines( iv_werks ) TO rt_line.
    APPEND LINES OF substitute_lines( iv_werks ) TO rt_line.
    APPEND LINES OF hold_lines( iv_werks ) TO rt_line.
    APPEND LINES OF priority_lines( iv_werks ) TO rt_line.
    APPEND LINES OF extension_lines( iv_werks ) TO rt_line.

    APPEND || TO rt_line.

    " the first line is the heading and the last is this one
    IF lines( rt_line ) = 2.
      APPEND `Nothing to correct` TO rt_line.
      RETURN.
    ENDIF.

    APPEND |{ lines( rt_line ) - 2 } thing(s) to look at| TO rt_line.

  ENDMETHOD.

  METHOD run_everywhere.

    DATA lv_plants TYPE i.

    SELECT werks
      FROM t001w
      ORDER BY werks
      INTO TABLE @DATA(lt_plant).
    IF sy-subrc <> 0.
      APPEND `There are no plants at all` TO rt_line.
      RETURN.
    ENDIF.

    LOOP AT lt_plant INTO DATA(ls_plant).

      TRY.
          APPEND LINES OF run( ls_plant-werks ) TO rt_line.
          APPEND || TO rt_line.
          lv_plants = lv_plants + 1.
        CATCH zcx_allocation.
          " not a plant of this user's, and not their problem
          CONTINUE.
      ENDTRY.

    ENDLOOP.

    IF lv_plants = 0.
      APPEND `No plant here is one you may look at` TO rt_line.
      RETURN.
    ENDIF.

    APPEND |{ lv_plants } plant(s) checked| TO rt_line.

  ENDMETHOD.

  METHOD plant_lines.

    SELECT SINGLE fabkl
      FROM t001w
      WHERE werks = @iv_werks
      INTO @DATA(lv_fabkl).
    IF sy-subrc <> 0.
      APPEND |The plant is not in T001W at all| TO rt_line.
      RETURN.
    ENDIF.

    SELECT SINGLE work_days
      FROM zstock_alloc_cfg
      WHERE werks = @iv_werks
      INTO @DATA(lv_work_days).
    IF sy-subrc = 0 AND lv_work_days = abap_true AND lv_fabkl IS INITIAL.
      APPEND |Shipping time counts working days, but the plant has no factory calendar| TO rt_line.
    ENDIF.

  ENDMETHOD.

  METHOD settings_lines.

    SELECT SINGLE strategy,
                  horizon_days,
                  cap_percent,
                  keep_days,
                  ship_days,
                  age_days,
                  min_percent,
                  firm_days
      FROM zstock_alloc_cfg
      WHERE werks = @iv_werks
      INTO @DATA(ls_cfg).
    " a plant with no row of its own runs on the defaults, which is a
    " decision rather than a mistake: the whole point of feature 36 is that
    " allocation works out of the box
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " the reader corrects each of these rather than obeying it, because a
    " nightly run must not stop for a typed minus. What it cannot do is say
    " so, and a setting quietly not doing what it says is what this is for.
    IF ls_cfg-strategy IS NOT INITIAL AND ls_cfg-strategy <> zcl_alloc_config=>c_fair_share.
      APPEND |Distribution rule { ls_cfg-strategy } is not one this knows, so it serves by priority| TO rt_line.
    ENDIF.

    IF ls_cfg-cap_percent > c_max_percent.
      APPEND |A customer share of { ls_cfg-cap_percent } percent is read as { c_max_percent }| TO rt_line.
    ENDIF.

    IF ls_cfg-min_percent > c_max_percent.
      APPEND |A smallest worthwhile confirmation of { ls_cfg-min_percent } percent | &&
             |is read as { c_max_percent }, which is the complete delivery rule| TO rt_line.
    ENDIF.

    IF ls_cfg-horizon_days < 0 OR ls_cfg-ship_days < 0
        OR ls_cfg-keep_days < 0 OR ls_cfg-age_days < 0
        OR ls_cfg-firm_days < 0.
      APPEND |A number of days below zero is read as none| TO rt_line.
    ENDIF.

  ENDMETHOD.

  METHOD quota_lines.

    SELECT matnr, kunnr, date_from, date_to, quantity
      FROM zstock_alloc_qta
      WHERE werks = @iv_werks
      ORDER BY matnr, kunnr, date_from
      INTO TABLE @DATA(lt_quota).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_quota INTO DATA(ls_quota).

      IF ls_quota-date_to < ls_quota-date_from.
        APPEND |Quota { ls_quota-matnr } { ls_quota-kunnr }: the period runs backwards, | &&
               |so it never applies| TO rt_line.
      ENDIF.

      IF ls_quota-quantity <= 0.
        APPEND |Quota { ls_quota-matnr } { ls_quota-kunnr }: nothing at all is allowed| TO rt_line.
      ENDIF.

      IF is_a_material( ls_quota-matnr ) = abap_false.
        APPEND |Quota { ls_quota-matnr }: no such material| TO rt_line.
      ELSEIF is_in_the_plant( iv_matnr = ls_quota-matnr
                              iv_werks = iv_werks ) = abap_false.
        APPEND |Quota { ls_quota-matnr }: the material is not in this plant| TO rt_line.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD promise_lines.

    SELECT matnr, demand_id, quantity, valid_to
      FROM zstock_alloc_fix
      WHERE werks = @iv_werks
      ORDER BY matnr, demand_id
      INTO TABLE @DATA(lt_promise).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_promise INTO DATA(ls_promise).

      IF ls_promise-quantity <= 0.
        APPEND |Promise { ls_promise-demand_id }: nothing is promised| TO rt_line.
      ENDIF.

      IF ls_promise-valid_to <> c_no_end AND ls_promise-valid_to < sy-datum.
        APPEND |Promise { ls_promise-demand_id }: ran out on | &&
               |{ ls_promise-valid_to DATE = ISO }, and is still there| TO rt_line.
      ENDIF.

      IF is_a_material( ls_promise-matnr ) = abap_false.
        APPEND |Promise { ls_promise-matnr }: no such material| TO rt_line.
      ELSEIF is_in_the_plant( iv_matnr = ls_promise-matnr
                              iv_werks = iv_werks ) = abap_false.
        APPEND |Promise { ls_promise-matnr }: the material is not in this plant| TO rt_line.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD substitute_lines.

    SELECT matnr, substitute, factor
      FROM zstock_alloc_sub
      WHERE werks = @iv_werks
      ORDER BY matnr, substitute
      INTO TABLE @DATA(lt_substitute).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_substitute INTO DATA(ls_substitute).

      IF ls_substitute-substitute = ls_substitute-matnr.
        APPEND |Substitute { ls_substitute-matnr }: stands in for itself| TO rt_line.
      ENDIF.

      IF ls_substitute-factor < 0.
        APPEND |Substitute { ls_substitute-substitute }: the factor is below zero| TO rt_line.
      ENDIF.

      IF is_a_material( ls_substitute-substitute ) = abap_false.
        APPEND |Substitute { ls_substitute-substitute }: no such material| TO rt_line.
      ELSEIF is_in_the_plant( iv_matnr = ls_substitute-substitute
                              iv_werks = iv_werks ) = abap_false.
        APPEND |Substitute { ls_substitute-substitute }: not in this plant, | &&
               |so it has nothing here to stand in with| TO rt_line.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD hold_lines.

    SELECT matnr, reason, until_date
      FROM zstock_alloc_hld
      WHERE werks = @iv_werks
      ORDER BY matnr
      INTO TABLE @DATA(lt_hold).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_hold INTO DATA(ls_hold).

      IF ls_hold-until_date <> c_no_end AND ls_hold-until_date < sy-datum.
        APPEND |Hold { ls_hold-matnr }: lifted on { ls_hold-until_date DATE = ISO }, | &&
               |and the row is still there| TO rt_line.
      ENDIF.

      " a hold with no reason on it is one nobody can argue with, and the
      " material stays out of every run until somebody guesses who set it
      IF ls_hold-reason IS INITIAL.
        APPEND |Hold { ls_hold-matnr }: no reason is given| TO rt_line.
      ENDIF.

      IF is_a_material( ls_hold-matnr ) = abap_false.
        APPEND |Hold { ls_hold-matnr }: no such material| TO rt_line.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD priority_lines.

    " the rows of this plant and the ones that apply everywhere, which is how
    " the reader reads them
    SELECT werks, kunnr, priority
      FROM zstock_alloc_pri
      WHERE werks = @iv_werks
         OR werks = @space
      ORDER BY werks, kunnr
      INTO TABLE @DATA(lt_rank).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_rank INTO DATA(ls_rank).

      " the reader takes an empty priority as "nothing was said", so a row
      " with one is a row that does nothing at all
      IF ls_rank-priority IS INITIAL.
        APPEND |Customer { ls_rank-kunnr }: no priority is set, so the row does nothing| TO rt_line.
      ENDIF.

      " demand with no customer is a stock transport order, which this never
      " looks at: a row without one cannot match anything
      IF ls_rank-kunnr IS INITIAL.
        APPEND |A customer priority row with no customer matches nothing| TO rt_line.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD extension_lines.

    " a class named here that nobody transported fails the whole plant on the
    " first material it reads, which is a bad way to find out
    SELECT kind, classname
      FROM zstock_alloc_ext
      WHERE werks = @iv_werks
         OR werks = @space
      ORDER BY kind, classname
      INTO TABLE @DATA(lt_ext).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_ext INTO DATA(ls_ext).

      TRY.
          DATA(lo_source) = zcl_alloc_extensions=>make( ls_ext-classname ).
        CATCH zcx_allocation.
          APPEND |Source { ls_ext-classname }: cannot be created| TO rt_line.
          CONTINUE.
      ENDTRY.

      TRY.
          IF ls_ext-kind = zcl_alloc_extensions=>c_supply.
            DATA(lo_supply) = CAST zif_supply_reader( lo_source ).
            CLEAR lo_supply.
          ELSE.
            DATA(lo_demand) = CAST zif_demand_reader( lo_source ).
            CLEAR lo_demand.
          ENDIF.
        CATCH cx_sy_move_cast_error.
          APPEND |Source { ls_ext-classname }: is not a reader of kind { ls_ext-kind }| TO rt_line.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

  METHOD is_in_the_plant.

    " a material that exists and was never extended to this plant is the
    " commonest of these mistakes: the row looks right, the material is real,
    " and the run will never see either of them together
    SELECT SINGLE matnr
      FROM marc
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
      INTO @DATA(lv_matnr).
    rv_there = xsdbool( sy-subrc = 0 AND lv_matnr IS NOT INITIAL ).

  ENDMETHOD.

  METHOD is_a_material.

    SELECT SINGLE matnr
      FROM mara
      WHERE matnr = @iv_matnr
      INTO @DATA(lv_matnr).
    rv_there = xsdbool( sy-subrc = 0 AND lv_matnr IS NOT INITIAL ).

  ENDMETHOD.

ENDCLASS.
