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


CLASS lcl_store_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

    METHODS constructor
      IMPORTING
        it_recorded TYPE zif_allocation_store=>ty_recorded_tab.

  PRIVATE SECTION.
    DATA mt_recorded TYPE zif_allocation_store=>ty_recorded_tab.

ENDCLASS.


CLASS lcl_store_double IMPLEMENTATION.

  METHOD constructor.
    mt_recorded = it_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.
    rt_recorded = mt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~save.
    " the list writes nothing
    CLEAR mt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~record_reservation.
    CLEAR mt_recorded.
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

  METHOD zif_allocation_store~delete_run.
    CLEAR mt_recorded.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    METHODS constructor
      IMPORTING
        iv_refuse TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    DATA mv_refuse TYPE abap_bool.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD constructor.
    mv_refuse = iv_refuse.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    IF mv_refuse = abap_true.
      RAISE EXCEPTION NEW zcx_allocation(
        textid   = zcx_allocation=>not_authorised
        mv_werks = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_substitute DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9271'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'SUB-MAT-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'SUB-MAT-02'.

    METHODS teardown.

    METHODS given_substitute
      IMPORTING
        iv_factor TYPE zif_allocation=>ty_quantity DEFAULT 1
        iv_matnr  TYPE zstock_alloc_sub-matnr DEFAULT c_matnr.

    METHODS lines_of
      IMPORTING
        iv_shortfall   TYPE zif_allocation=>ty_quantity DEFAULT 40
        iv_now         TYPE zif_allocation=>ty_quantity DEFAULT 100
        iv_later       TYPE zif_allocation=>ty_quantity DEFAULT 0
        iv_refuse      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_substitute=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS says
      IMPORTING
        it_line       TYPE zcl_alloc_substitute=>ty_line_tab
        iv_text       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS nothing_short_says_so FOR TESTING RAISING cx_static_check.
    METHODS a_material_without_one FOR TESTING RAISING cx_static_check.
    METHODS what_it_has_is_shown FOR TESTING RAISING cx_static_check.
    METHODS what_is_coming_is_apart FOR TESTING RAISING cx_static_check.
    METHODS the_factor_is_applied FOR TESTING RAISING cx_static_check.
    METHODS it_covers_at_most_the_gap FOR TESTING RAISING cx_static_check.
    METHODS a_closed_plant_is_refused FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_substitute IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM zstock_alloc_sub WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_substitute.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_sub WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        werks      = c_werks
        matnr      = iv_matnr
        substitute = c_other
        factor     = iv_factor
        note       = 'the customer has taken it before' ) ).

    INSERT zstock_alloc_sub FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD lines_of.

    DATA lt_supply TYPE zif_supply_reader=>ty_supply_tab.

    APPEND VALUE #( quantity = iv_now ) TO lt_supply.
    IF iv_later > 0.
      APPEND VALUE #( avail_date = '20260701'
                      quantity   = iv_later ) TO lt_supply.
    ENDIF.

    rt_line = NEW zcl_alloc_substitute(
      io_supply    = NEW lcl_supply_double( lt_supply )
      io_store     = NEW lcl_store_double( VALUE #(
        ( matnr     = c_matnr
          run_id    = 'SUB-RUN'
          demand_id = 'SUB-D1'
          requested = 100
          confirmed = 100 - iv_shortfall
          shortfall = iv_shortfall ) ) )
      io_authority = NEW lcl_authority_double( iv_refuse ) )->run( c_werks ).

  ENDMETHOD.

  METHOD says.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CS iv_text.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD nothing_short_says_so.

    given_substitute( ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lines_of( iv_shortfall = 0 )
                  iv_text = `Nothing was short in the last run` )
      msg = 'a plant that served everything is not a plant with a problem' ).

  ENDMETHOD.

  METHOD a_material_without_one.

    given_substitute( iv_matnr = 'SUB-MAT-09' ).

    " short, but nothing the plant has said could stand in for it
    cl_abap_unit_assert=>assert_false( says( it_line = lines_of( )
                                             iv_text = |{ c_other }| ) ).

  ENDMETHOD.

  METHOD what_it_has_is_shown.

    given_substitute( ).

    DATA(lt_line) = lines_of( ).

    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = |{ c_other }| ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `100.000` ) ).
    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `the customer has taken it before` )
      msg = 'what a planner needs to know about a substitute goes with it' ).

  ENDMETHOD.

  METHOD what_is_coming_is_apart.

    given_substitute( ).

    " stock on the shelf and stock on its way are different offers to make a
    " customer, and one column of the two of them added up is neither
    DATA(lt_line) = lines_of( iv_now   = 5
                              iv_later = 30 ).

    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `5.000` ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `30.000` ) ).

  ENDMETHOD.

  METHOD the_factor_is_applied.

    given_substitute( iv_factor = 2 ).

    " two of the substitute make one of the material, so twenty on the shelf
    " cover ten of a gap of forty
    cl_abap_unit_assert=>assert_true( says(
      it_line = lines_of( iv_now = 20 )
      iv_text = `10.000` ) ).

  ENDMETHOD.

  METHOD it_covers_at_most_the_gap.

    given_substitute( ).

    " a warehouse full of the substitute still only covers what is short: the
    " column is what it would do for this problem
    cl_abap_unit_assert=>assert_true( says(
      it_line = lines_of( iv_shortfall = 4
                          iv_now       = 1000 )
      iv_text = `4.000` ) ).

  ENDMETHOD.

  METHOD a_closed_plant_is_refused.

    TRY.
        lines_of( iv_refuse = abap_true ).
        cl_abap_unit_assert=>fail( 'what a plant is short of is the plant''s business' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
