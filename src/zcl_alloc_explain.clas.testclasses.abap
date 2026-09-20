"! Says the same thing about every material it is asked about.
CLASS lcl_firm_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_alloc_floor.

    METHODS constructor
      IMPORTING
        it_floor TYPE zif_alloc_floor=>ty_floor_tab.

  PRIVATE SECTION.
    DATA mt_floor TYPE zif_alloc_floor=>ty_floor_tab.

ENDCLASS.


CLASS lcl_firm_double IMPLEMENTATION.

  METHOD constructor.
    mt_floor = it_floor.
  ENDMETHOD.

  METHOD zif_alloc_floor~floors_for.
    rt_floor = mt_floor.
  ENDMETHOD.

ENDCLASS.


"! Answers with a fixed timeline.
CLASS lcl_supply_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    METHODS constructor
      IMPORTING
        it_supply TYPE zif_supply_reader=>ty_supply_tab.

  PRIVATE SECTION.
    DATA mt_supply TYPE zif_supply_reader=>ty_supply_tab.

ENDCLASS.


CLASS lcl_supply_double IMPLEMENTATION.

  METHOD constructor.
    mt_supply = it_supply.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.
    rt_supply = mt_supply.
  ENDMETHOD.

ENDCLASS.


"! Answers with a fixed demand.
CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab.

  PRIVATE SECTION.
    DATA mt_demand TYPE zif_allocation=>ty_demand_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_demand = it_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    rt_demand = mt_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    CLEAR rt_matnr.
  ENDMETHOD.

ENDCLASS.


"! Allows every plant, and remembers which one it was asked about.
CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    METHODS get_plant
      RETURNING
        VALUE(rv_werks) TYPE mard-werks.

  PRIVATE SECTION.
    DATA mv_werks TYPE mard-werks.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD get_plant.
    rv_werks = mv_werks.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.
    mv_werks = iv_werks.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_explain DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'EXPLAIN-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_authority TYPE REF TO lcl_authority_double.

    METHODS setup.

    METHODS says
      IMPORTING
        it_line       TYPE zcl_alloc_explain=>ty_line_tab
        iv_text       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS explained
      IMPORTING
        it_supply      TYPE zif_supply_reader=>ty_supply_tab
        it_demand      TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_explain=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS the_supply_is_listed FOR TESTING RAISING cx_static_check.
    METHODS the_demand_is_listed FOR TESTING RAISING cx_static_check.
    METHODS the_answer_is_worked_out FOR TESTING RAISING cx_static_check.
    METHODS a_short_line_says_why FOR TESTING RAISING cx_static_check.
    METHODS a_grouped_line_says_so FOR TESTING RAISING cx_static_check.
    METHODS a_complete_line_says_so FOR TESTING RAISING cx_static_check.
    METHODS a_plain_line_says_nothing FOR TESTING RAISING cx_static_check.
    METHODS an_empty_material_says_so FOR TESTING RAISING cx_static_check.
    METHODS what_is_taken_care_of_shows FOR TESTING RAISING cx_static_check.
    METHODS a_hold_is_said_out_loud FOR TESTING RAISING cx_static_check.
    METHODS the_plant_is_checked FOR TESTING RAISING cx_static_check.
    METHODS a_promise_is_said_out_loud FOR TESTING RAISING cx_static_check.
    METHODS a_quota_is_said_out_loud FOR TESTING RAISING cx_static_check.
    METHODS the_unit_is_on_the_heading FOR TESTING RAISING cx_static_check.
    METHODS nobody_ever_ordered_it FOR TESTING RAISING cx_static_check.
    METHODS a_deletion_flag_is_said FOR TESTING RAISING cx_static_check.
    METHODS every_line_thrown_out FOR TESTING RAISING cx_static_check.
    METHODS what_is_firm_is_said FOR TESTING RAISING cx_static_check.
    METHODS no_firm_zone_says_nothing FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_explain IMPLEMENTATION.

  METHOD setup.
    mo_authority = NEW lcl_authority_double( ).
  ENDMETHOD.

  METHOD says.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CS iv_text.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD explained.

    DATA(lo_supply) = CAST zif_supply_reader( NEW lcl_supply_double( it_supply ) ).
    DATA(lo_demand) = CAST zif_demand_reader( NEW lcl_demand_double( it_demand ) ).

    DATA(lo_cut) = NEW zcl_alloc_explain(
      io_supply    = lo_supply
      io_demand    = lo_demand
      io_engine    = NEW zcl_allocation_engine(
        io_supply_reader = lo_supply
        io_demand_reader = lo_demand
        io_strategy      = NEW zcl_alloc_strategy_priority( ) )
      io_authority = mo_authority ).

    rt_line = lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD the_supply_is_listed.

    DATA(lt_line) = explained(
      it_supply = VALUE #(
        ( avail_date = '00000000' quantity = '10' )
        ( avail_date = '20260301' quantity = '5' ) )
      it_demand = VALUE #( ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 4 ]
      exp = '*now*10*'
      msg = 'what is on the shelf is the first day of the timeline' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 5 ]
      exp = '*2026-03-01*5*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 6 ]
      exp = '*Total*15*'
      msg = 'the total is what the run had to hand out' ).

  ENDMETHOD.

  METHOD the_demand_is_listed.

    DATA(lt_line) = explained(
      it_supply = VALUE #( ( avail_date = '00000000' quantity = '10' ) )
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '4' req_date = '20260210' priority = '02' ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 8 ]
      exp = '*D1*2026-02-10*4*02*'
      msg = 'every line competing for the stock, with what makes it compete' ).

  ENDMETHOD.

  METHOD the_answer_is_worked_out.

    DATA(lt_line) = explained(
      it_supply = VALUE #( ( avail_date = '00000000' quantity = '10' ) )
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '4' req_date = '20260210' priority = '02' ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 12 ]
      exp = '*D1*4*'
      msg = 'and what the two of them come to today, not last night' ).

  ENDMETHOD.

  METHOD a_short_line_says_why.

    DATA(lt_line) = explained(
      it_supply = VALUE #( ( avail_date = '00000000' quantity = '3' ) )
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260210' priority = '02' ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 12 ]
      exp = '*not enough stock*'
      msg = 'the working and the reason belong on the same page' ).

  ENDMETHOD.

  METHOD a_grouped_line_says_so.

    DATA(lt_line) = explained(
      it_supply = VALUE #( ( avail_date = '00000000' quantity = '10' ) )
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '4' req_date = '20260210' priority = '02'
          ship_group = '0000004716' ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 8 ]
      exp = '*ships with 0000004716*'
      msg = 'a line waiting for the rest of its order has to say which order' ).

  ENDMETHOD.

  METHOD a_complete_line_says_so.

    DATA(lt_line) = explained(
      it_supply = VALUE #( ( avail_date = '00000000' quantity = '10' ) )
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '4' req_date = '20260210' priority = '02'
          complete = abap_true ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 8 ]
      exp = '*in one delivery*' ).

  ENDMETHOD.

  METHOD a_plain_line_says_nothing.

    DATA(lt_line) = explained(
      it_supply = VALUE #( ( avail_date = '00000000' quantity = '10' ) )
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '4' req_date = '20260210' priority = '02' ) ) ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( lt_line[ 8 ] CS `delivery` OR lt_line[ 8 ] CS `ships with` )
      msg = 'a page that notes what every line is free to do is a page nobody reads' ).

  ENDMETHOD.

  METHOD an_empty_material_says_so.

    DATA(lt_line) = explained(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 4 ]
      exp = '*nothing*'
      msg = 'an empty timeline is an answer, and an empty page is not' ).

  ENDMETHOD.

  METHOD what_is_taken_care_of_shows.

    " the order asks for ten, four have gone out already, so the run sees six
    DATA(lo_supply) = CAST zif_supply_reader( NEW lcl_supply_double( VALUE #(
      ( avail_date = '00000000' quantity = '10' ) ) ) ).
    DATA(lo_demand) = CAST zif_demand_reader( NEW lcl_demand_double( VALUE #(
      ( demand_id = 'D1' matnr = c_matnr werks = c_werks
        quantity = '6' req_date = '20260210' priority = '02' ) ) ) ).
    DATA(lo_gross)  = CAST zif_demand_reader( NEW lcl_demand_double( VALUE #(
      ( demand_id = 'D1' matnr = c_matnr werks = c_werks
        quantity = '10' req_date = '20260210' priority = '02' ) ) ) ).

    DATA(lo_cut) = NEW zcl_alloc_explain(
      io_supply    = lo_supply
      io_demand    = lo_demand
      io_gross     = lo_gross
      io_engine    = NEW zcl_allocation_engine(
        io_supply_reader = lo_supply
        io_demand_reader = lo_demand
        io_strategy      = NEW zcl_alloc_strategy_priority( ) )
      io_authority = mo_authority ).

    DATA(lt_line) = lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 8 ]
      exp = '*6.000*4.000*'
      msg = 'a line of ten asking for six should say where the other four went' ).

  ENDMETHOD.

  METHOD a_hold_is_said_out_loud.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_hld WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt  = sy-mandt
        werks  = c_werks
        matnr  = c_matnr
        reason = 'counting the last pallet again' ) ).
    INSERT zstock_alloc_hld FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

    DATA(lt_line) = explained(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    DELETE FROM zstock_alloc_hld WHERE werks = @c_werks AND matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*counting the last pallet again*'
      msg = 'a material on hold reads as a material nobody wants unless it says so' ).

  ENDMETHOD.

  METHOD the_plant_is_checked.

    explained(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->get_plant( )
      exp = c_werks
      msg = 'this is a plant stock situation, and not everybody may see it' ).

  ENDMETHOD.

  METHOD a_promise_is_said_out_loud.

    DATA lt_row  TYPE STANDARD TABLE OF zstock_alloc_fix WITH EMPTY KEY.
    DATA lv_said TYPE abap_bool.

    lt_row = VALUE #(
      ( mandt     = sy-mandt
        werks     = c_werks
        matnr     = c_matnr
        demand_id = 'EXPLAIN-D1'
        quantity  = 6
        reason    = 'promised at the trade fair' ) ).
    INSERT zstock_alloc_fix FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

    DATA(lt_line) = explained(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    DELETE FROM zstock_alloc_fix WHERE werks = @c_werks AND matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    LOOP AT lt_line INTO DATA(lv_line).
      IF lv_line CS 'promised at the trade fair'.
        lv_said = abap_true.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals(
      act = lv_said
      exp = abap_true
      msg = 'an answer that does not follow from the priorities has to say what it does follow from' ).

  ENDMETHOD.

  METHOD a_quota_is_said_out_loud.

    DATA lt_row  TYPE STANDARD TABLE OF zstock_alloc_qta WITH EMPTY KEY.
    DATA lv_said TYPE abap_bool.

    lt_row = VALUE #(
      ( mandt     = sy-mandt
        werks     = c_werks
        matnr     = c_matnr
        kunnr     = 'EXPLCUST'
        date_from = '20260101'
        date_to   = '20261231'
        quantity  = 30 ) ).
    INSERT zstock_alloc_qta FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

    DATA(lt_line) = explained(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    DELETE FROM zstock_alloc_qta WHERE werks = @c_werks AND matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    LOOP AT lt_line INTO DATA(lv_line).
      IF lv_line CS 'EXPLCUST'.
        lv_said = abap_true.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals(
      act = lv_said
      exp = abap_true
      msg = 'the quota that cut the line is part of the working' ).

  ENDMETHOD.

  METHOD the_unit_is_on_the_heading.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = 'KG' ) ).
    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_subrc( ).

    DATA(lt_line) = explained(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_subrc( ).

    " a page of numbers that does not say what they are quantities of asks
    " the reader to know
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 1 ]
      exp = '*quantities in KG*' ).

  ENDMETHOD.

  METHOD nobody_ever_ordered_it.

    DATA(lt_line) = explained(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    " "nothing is waiting" is true of a material nobody has ordered and of one
    " whose orders were all thrown out, and they are not the same news
    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `no sales order line has ever asked for it here` )
      msg = 'an empty page has to say which kind of empty it is' ).

  ENDMETHOD.

  METHOD a_deletion_flag_is_said.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = 'PC' lvorm = 'X' ) ).
    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_subrc( ).

    DATA(lt_line) = explained(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `flagged for deletion` ) ).

  ENDMETHOD.

  METHOD every_line_thrown_out.

    DATA lt_vbap TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.

    lt_vbap = VALUE #(
      ( mandt = sy-mandt vbeln = '0000098001' posnr = '000010'
        matnr = c_matnr werks = c_werks vrkme = 'PC' kwmeng = '10'
        lprio = '01' abgru = '01' ) ).
    INSERT vbap FROM TABLE @lt_vbap.
    cl_abap_unit_assert=>assert_subrc( ).

    DATA(lt_line) = explained(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    DELETE FROM vbap WHERE vbeln = '0000098001'.
    cl_abap_unit_assert=>assert_subrc( ).

    " a rejected line is still a line somebody typed, and "none of them
    " counts" is the answer that stops a planner looking for the order
    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `none of them counts` )
      msg = 'a material with orders and no demand is the confusing case' ).

  ENDMETHOD.

  METHOD what_is_firm_is_said.

    DATA(lo_supply) = CAST zif_supply_reader( NEW lcl_supply_double( VALUE #(
      ( avail_date = '00000000' quantity = '10' ) ) ) ).
    DATA(lo_demand) = CAST zif_demand_reader( NEW lcl_demand_double( VALUE #(
      ( demand_id = 'D1' matnr = c_matnr werks = c_werks
        quantity = '10' req_date = '20260210' priority = '02' ) ) ) ).

    DATA(lo_cut) = NEW zcl_alloc_explain(
      io_supply    = lo_supply
      io_demand    = lo_demand
      io_engine    = NEW zcl_allocation_engine(
        io_supply_reader = lo_supply
        io_demand_reader = lo_demand
        io_strategy      = NEW zcl_alloc_strategy_priority( ) )
      io_authority = mo_authority
      io_firm      = NEW lcl_firm_double( VALUE #( ( demand_id = 'D1' quantity = 4 ) ) ) ).

    " "confirmed" contains "firm" and CS does not care about case, so the
    " whole heading is asked for rather than the word
    " a page that shows the priorities and not the firm zone explains an
    " answer that does not follow from the priorities
    cl_abap_unit_assert=>assert_true( says(
      it_line = lo_cut->run( iv_matnr = c_matnr
                             iv_werks = c_werks )
      iv_text = `Firm, and served` ) ).

  ENDMETHOD.

  METHOD no_firm_zone_says_nothing.

    cl_abap_unit_assert=>assert_false( says(
      it_line = explained(
        it_supply = VALUE #( ( avail_date = '00000000' quantity = '10' ) )
        it_demand = VALUE #( ( demand_id = 'D1' matnr = c_matnr werks = c_werks
                               quantity = '10' req_date = '20260210' priority = '02' ) ) )
      iv_text = `Firm, and served` ) ).

  ENDMETHOD.

ENDCLASS.
