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

    LOOP AT mt_recorded INTO DATA(ls_recorded).
      IF ls_recorded-run_id = iv_werks.
        APPEND ls_recorded TO rt_recorded.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_allocation_store~save.
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


CLASS ltcl_alloc_plant_list DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9621'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'PLTS-MAT-01'.

    METHODS setup.
    METHODS teardown.

    METHODS lines_of
      IMPORTING
        it_recorded    TYPE zif_allocation_store=>ty_recorded_tab
        iv_refuse      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_plant_list=>ty_line_tab.

    METHODS recorded
      IMPORTING
        iv_matnr           TYPE mard-matnr
        iv_shortfall       TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rs_recorded) TYPE zif_allocation_store=>ty_recorded.

    METHODS says
      IMPORTING
        it_line       TYPE zcl_alloc_plant_list=>ty_line_tab
        iv_text       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS a_plant_is_summed_up FOR TESTING.
    METHODS a_plant_with_nothing_short FOR TESTING.
    METHODS plants_not_yours_are_left_out FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_plant_list IMPLEMENTATION.

  METHOD setup.

    DATA lt_t001w TYPE STANDARD TABLE OF t001w WITH EMPTY KEY.

    lt_t001w = VALUE #(
      ( mandt = sy-mandt werks = c_werks name1 = 'Overview plant' fabkl = '01' ) ).
    INSERT t001w FROM TABLE @lt_t001w.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM t001w WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD recorded.

    " the double answers per plant by matching the run id against it, which
    " keeps the fixture to one table
    rs_recorded = VALUE #(
      matnr     = iv_matnr
      run_id    = c_werks
      demand_id = |{ iv_matnr }-D1|
      requested = 100
      confirmed = 100 - iv_shortfall
      shortfall = iv_shortfall ).

  ENDMETHOD.

  METHOD lines_of.

    rt_line = NEW zcl_alloc_plant_list(
      io_store     = NEW lcl_store_double( it_recorded )
      io_authority = NEW lcl_authority_double( iv_refuse ) )->run( ).

  ENDMETHOD.

  METHOD says.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CS iv_text.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD a_plant_is_summed_up.

    DATA(lt_line) = lines_of( VALUE #(
      ( recorded( iv_matnr     = c_matnr
                  iv_shortfall = 40 ) )
      ( recorded( iv_matnr     = 'PLTS-MAT-02'
                  iv_shortfall = 10 ) ) ) ).

    " two materials, two short lines, fifty short between them
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = |{ c_werks }| ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `50.000` ) ).

  ENDMETHOD.

  METHOD a_plant_with_nothing_short.

    DATA(lt_line) = lines_of( VALUE #(
      ( recorded( iv_matnr     = c_matnr
                  iv_shortfall = 0 ) ) ) ).

    " a plant that served everything still gets a line: "nothing short here"
    " is the answer somebody is looking for at seven in the morning
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = |{ c_werks }| ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `0.000` ) ).

  ENDMETHOD.

  METHOD plants_not_yours_are_left_out.

    DATA(lt_line) = lines_of(
      it_recorded = VALUE #( ( recorded( iv_matnr     = c_matnr
                                         iv_shortfall = 40 ) ) )
      iv_refuse   = abap_true ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `No plant here is one you may look at` )
      msg = 'a page that refuses at the first plant somebody does not own is unreadable' ).

  ENDMETHOD.

ENDCLASS.
