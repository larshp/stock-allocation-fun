"! Answers with a fixed set of recorded lines.
CLASS lcl_store_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

    METHODS constructor
      IMPORTING
        it_recorded TYPE zif_allocation_store=>ty_recorded_tab.

  PRIVATE SECTION.
    DATA mt_recorded TYPE zif_allocation_store=>ty_recorded_tab.
    DATA mv_written  TYPE abap_bool.

ENDCLASS.


CLASS lcl_store_double IMPLEMENTATION.

  METHOD constructor.
    mt_recorded = it_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.
    rt_recorded = mt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~save.
    " a summary only reads
    CLEAR mv_written.
  ENDMETHOD.

  METHOD zif_allocation_store~read.
    CLEAR rt_allocation.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_recorded_before.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_of_material.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~record_reservation.
    CLEAR mv_written.
  ENDMETHOD.

  METHOD zif_allocation_store~delete_run.
    CLEAR mv_written.
  ENDMETHOD.

ENDCLASS.


"! Allows every plant.
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


CLASS ltcl_reason_mix DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_authority TYPE REF TO lcl_authority_double.

    METHODS setup.

    METHODS recorded
      IMPORTING
        iv_matnr           TYPE mard-matnr
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
        iv_short           TYPE zif_allocation=>ty_quantity
        iv_reason          TYPE zif_allocation=>ty_reason DEFAULT 'S'
        iv_customer        TYPE vbak-kunnr DEFAULT '0000040001'
      RETURNING
        VALUE(rs_recorded) TYPE zif_allocation_store=>ty_recorded.

    METHODS mix_of
      IMPORTING
        it_recorded    TYPE zif_allocation_store=>ty_recorded_tab
        iv_kunnr       TYPE vbak-kunnr OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_reason_mix=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS found
      IMPORTING
        it_line         TYPE zcl_alloc_reason_mix=>ty_line_tab
        iv_pattern      TYPE string
      RETURNING
        VALUE(rv_found) TYPE abap_bool.

    METHODS an_empty_plant_says_so FOR TESTING RAISING cx_static_check.
    METHODS a_plant_with_nothing_short FOR TESTING RAISING cx_static_check.
    METHODS the_supply_side_is_its_own FOR TESTING RAISING cx_static_check.
    METHODS the_rules_side_is_its_own FOR TESTING RAISING cx_static_check.
    METHODS an_empty_side_has_no_heading FOR TESTING RAISING cx_static_check.
    METHODS the_biggest_reason_first FOR TESTING RAISING cx_static_check.
    METHODS the_share_is_of_the_short FOR TESTING RAISING cx_static_check.
    METHODS materials_are_counted_once FOR TESTING RAISING cx_static_check.
    METHODS a_full_line_is_not_short FOR TESTING RAISING cx_static_check.
    METHODS one_customer_can_be_asked FOR TESTING RAISING cx_static_check.
    METHODS an_unknown_reason_is_kept FOR TESTING RAISING cx_static_check.
    METHODS the_plant_is_checked FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_reason_mix IMPLEMENTATION.

  METHOD setup.
    mo_authority = NEW lcl_authority_double( ).
  ENDMETHOD.

  METHOD recorded.

    rs_recorded = VALUE #(
      matnr     = iv_matnr
      run_id    = 'RUN-0001'
      demand_id = iv_demand_id
      req_date  = '20260301'
      requested = iv_short
      confirmed = 0
      shortfall = iv_short
      reason    = iv_reason
      customer  = iv_customer ).

  ENDMETHOD.

  METHOD mix_of.

    DATA(lo_cut) = NEW zcl_alloc_reason_mix(
      io_store     = NEW lcl_store_double( it_recorded )
      io_authority = mo_authority ).

    rt_line = lo_cut->run(
      iv_werks = c_werks
      iv_kunnr = iv_kunnr ).

  ENDMETHOD.

  METHOD found.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CP iv_pattern.
        rv_found = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD an_empty_plant_says_so.

    DATA(lt_line) = mix_of( VALUE #( ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*Nothing has been allocated here yet*'
      msg = 'a plant that has never run is not a plant with no problems' ).

  ENDMETHOD.

  METHOD a_plant_with_nothing_short.

    DATA(lt_line) = mix_of( VALUE #(
      ( matnr = 'MAT-1' demand_id = 'D1' requested = '10'
        confirmed = '10' shortfall = 0 ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*none of them short*'
      msg = 'a good night is one line, not four empty headings' ).

  ENDMETHOD.

  METHOD the_supply_side_is_its_own.

    DATA(lt_line) = mix_of( VALUE #(
      ( recorded( iv_matnr     = 'MAT-1'
                  iv_demand_id = 'D1'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-no_stock ) ) ) ).

    cl_abap_unit_assert=>assert_true(
      act = found( it_line    = lt_line
                   iv_pattern = '*Stock that is not there*' )
      msg = 'stock that never arrived is a conversation with purchasing' ).
    cl_abap_unit_assert=>assert_false( found( it_line    = lt_line
                                              iv_pattern = '*Rules this plant chose*' ) ).

  ENDMETHOD.

  METHOD the_rules_side_is_its_own.

    DATA(lt_line) = mix_of( VALUE #(
      ( recorded( iv_matnr     = 'MAT-1'
                  iv_demand_id = 'D1'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-quota ) ) ) ).

    cl_abap_unit_assert=>assert_true(
      act = found( it_line    = lt_line
                   iv_pattern = '*Rules this plant chose*' )
      msg = 'a quota is the business holding stock back from itself' ).
    cl_abap_unit_assert=>assert_false( found( it_line    = lt_line
                                              iv_pattern = '*Stock that is not there*' ) ).

  ENDMETHOD.

  METHOD an_empty_side_has_no_heading.

    " the same rule the explanation follows: a heading with nothing under it
    " is a line that makes the page longer and says nothing
    DATA(lt_line) = mix_of( VALUE #(
      ( recorded( iv_matnr     = 'MAT-1'
                  iv_demand_id = 'D1'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-no_stock ) ) ) ).

    cl_abap_unit_assert=>assert_false( found( it_line    = lt_line
                                              iv_pattern = |*somebody's own*| ) ).

  ENDMETHOD.

  METHOD the_biggest_reason_first.

    DATA(lt_line) = mix_of( VALUE #(
      ( recorded( iv_matnr     = 'MAT-1'
                  iv_demand_id = 'D1'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-no_stock ) )
      ( recorded( iv_matnr     = 'MAT-2'
                  iv_demand_id = 'D2'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-supply_late ) )
      ( recorded( iv_matnr     = 'MAT-3'
                  iv_demand_id = 'D3'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-supply_late ) ) ) ).

    " heading, blank, block heading, column heading, then the biggest
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 5 ]
      exp = '*stock comes too late*2*'
      msg = 'the reason that cost the most lines is the one to read first' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 6 ]
      exp = '*not enough stock*1*' ).

  ENDMETHOD.

  METHOD the_share_is_of_the_short.

    " three short lines, one of them held back by a quota: a third
    DATA(lt_line) = mix_of( VALUE #(
      ( recorded( iv_matnr     = 'MAT-1'
                  iv_demand_id = 'D1'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-no_stock ) )
      ( recorded( iv_matnr     = 'MAT-2'
                  iv_demand_id = 'D2'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-no_stock ) )
      ( recorded( iv_matnr     = 'MAT-3'
                  iv_demand_id = 'D3'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-quota ) ) ) ).

    cl_abap_unit_assert=>assert_true(
      act = found( it_line    = lt_line
                   iv_pattern = '*customer quota*1*33%*' )
      msg = 'the share says how much of the plants shortfall one rule accounts for' ).

  ENDMETHOD.

  METHOD materials_are_counted_once.

    " one material, two short lines, one reason: a material to look at rather
    " than a rule to look at, and the count is what says which
    DATA(lt_line) = mix_of( VALUE #(
      ( recorded( iv_matnr     = 'MAT-1'
                  iv_demand_id = 'D1'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-no_stock ) )
      ( recorded( iv_matnr     = 'MAT-1'
                  iv_demand_id = 'D2'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-no_stock ) ) ) ).

    cl_abap_unit_assert=>assert_true(
      act = found( it_line    = lt_line
                   iv_pattern = '*not enough stock*2*100%*1*' )
      msg = 'two lines of one material are two lines and one material' ).

  ENDMETHOD.

  METHOD a_full_line_is_not_short.

    DATA(lt_line) = mix_of( VALUE #(
      ( recorded( iv_matnr     = 'MAT-1'
                  iv_demand_id = 'D1'
                  iv_short     = '10'
                  iv_reason    = zif_allocation=>c_reason-no_stock ) )
      ( matnr = 'MAT-2' demand_id = 'D2' requested = '10'
        confirmed = '10' shortfall = 0 ) ) ).

    " both lines were answered, one of them fell short
    cl_abap_unit_assert=>assert_true( found(
      it_line    = lt_line
      iv_pattern = '*2 line(s) answered*2 material(s), 1 short (50%)*' ) ).

  ENDMETHOD.

  METHOD one_customer_can_be_asked.

    DATA(lt_line) = mix_of(
      it_recorded = VALUE #(
        ( recorded( iv_matnr     = 'MAT-1'
                    iv_demand_id = 'D1'
                    iv_short     = '10'
                    iv_reason    = zif_allocation=>c_reason-no_stock
                    iv_customer  = '0000040001' ) )
        ( recorded( iv_matnr     = 'MAT-2'
                    iv_demand_id = 'D2'
                    iv_short     = '10'
                    iv_reason    = zif_allocation=>c_reason-quota
                    iv_customer  = '0000040002' ) ) )
      iv_kunnr    = '0000040002' ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*customer quota*' ) ).
    cl_abap_unit_assert=>assert_false(
      act = found( it_line    = lt_line
                   iv_pattern = '*not enough stock*' )
      msg = 'asking about one customer is asking what to tell them, nobody else' ).

  ENDMETHOD.

  METHOD an_unknown_reason_is_kept.

    " a strategy somebody wrote for their own system answers with a letter
    " nobody here knows, and a page that dropped it would say the plant was
    " short of nothing in particular
    DATA(lt_line) = mix_of( VALUE #(
      ( recorded( iv_matnr     = 'MAT-1'
                  iv_demand_id = 'D1'
                  iv_short     = '10'
                  iv_reason    = 'Z' ) ) ) ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = |*somebody's own*| ) ).
    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*Z*1*100%*' ) ).

  ENDMETHOD.

  METHOD the_plant_is_checked.

    mix_of( VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->get_plant( )
      exp = c_werks
      msg = 'a page that shows what a plant decided is a page not everybody may see' ).

  ENDMETHOD.

ENDCLASS.
