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


CLASS ltcl_alloc_quota_list DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9301'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'QTL-MAT-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'QTL-MAT-02'.
    CONSTANTS c_big   TYPE vbak-kunnr VALUE 'QTLBIG'.
    CONSTANTS c_small TYPE vbak-kunnr VALUE 'QTLSMALL'.
    CONSTANTS c_from  TYPE d VALUE '20260301'.
    CONSTANTS c_to    TYPE d VALUE '20260331'.

    METHODS teardown.

    METHODS given_quota
      IMPORTING
        iv_quantity TYPE zif_allocation=>ty_quantity
        iv_kunnr    TYPE zstock_alloc_qta-kunnr DEFAULT c_big
        iv_matnr    TYPE zstock_alloc_qta-matnr DEFAULT c_matnr.

    METHODS recorded
      IMPORTING
        iv_confirmed       TYPE zif_allocation=>ty_quantity
        iv_kunnr           TYPE vbak-kunnr DEFAULT c_big
        iv_matnr           TYPE mard-matnr DEFAULT c_matnr
        iv_req_date        TYPE d DEFAULT '20260315'
      RETURNING
        VALUE(rs_recorded) TYPE zif_allocation_store=>ty_recorded.

    METHODS list
      IMPORTING
        it_recorded    TYPE zif_allocation_store=>ty_recorded_tab
        iv_refuse      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_quota_list=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS says
      IMPORTING
        it_line       TYPE zcl_alloc_quota_list=>ty_line_tab
        iv_text       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS a_plant_without_quotas FOR TESTING RAISING cx_static_check.
    METHODS what_is_left_is_worked_out FOR TESTING RAISING cx_static_check.
    METHODS an_untouched_quota_is_shown FOR TESTING RAISING cx_static_check.
    METHODS another_month_does_not_count FOR TESTING RAISING cx_static_check.
    METHODS another_material_is_apart FOR TESTING RAISING cx_static_check.
    METHODS the_house_rule_is_per_customer FOR TESTING RAISING cx_static_check.
    METHODS a_closed_plant_is_refused FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_quota_list IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM zstock_alloc_qta WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_quota.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_qta WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt     = sy-mandt
        werks     = c_werks
        matnr     = iv_matnr
        kunnr     = iv_kunnr
        date_from = c_from
        date_to   = c_to
        quantity  = iv_quantity ) ).

    INSERT zstock_alloc_qta FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD recorded.

    rs_recorded = VALUE #(
      matnr     = iv_matnr
      run_id    = 'QTL-RUN'
      demand_id = |{ iv_kunnr }{ iv_req_date }|
      req_date  = iv_req_date
      requested = iv_confirmed
      confirmed = iv_confirmed
      customer  = iv_kunnr ).

  ENDMETHOD.

  METHOD list.

    rt_line = NEW zcl_alloc_quota_list(
      io_store     = NEW lcl_store_double( it_recorded )
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

  METHOD a_plant_without_quotas.

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = list( VALUE #( ) )
                  iv_text = `No quota is agreed here` )
      msg = 'a plant that has agreed nothing is not an empty page' ).

  ENDMETHOD.

  METHOD what_is_left_is_worked_out.

    given_quota( 100 ).

    DATA(lt_line) = list( VALUE #( ( recorded( 30 ) )
                                   ( recorded( iv_confirmed = 20
                                               iv_req_date  = '20260320' ) ) ) ).

    " fifty taken of a hundred agreed, over two lines of the same run
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `50.000` ) ).

  ENDMETHOD.

  METHOD an_untouched_quota_is_shown.

    given_quota( 100 ).

    DATA(lt_line) = list( VALUE #( ) ).

    " the row nobody has taken anything against is the one worth seeing: a
    " promise nobody is using, or a figure typed wrongly
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `QTLBIG` ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `0.000` ) ).

  ENDMETHOD.

  METHOD another_month_does_not_count.

    given_quota( 100 ).

    DATA(lt_line) = list( VALUE #( ( recorded( iv_confirmed = 30
                                               iv_req_date  = '20260415' ) ) ) ).

    cl_abap_unit_assert=>assert_false(
      act = says( it_line = lt_line
                  iv_text = `30.000` )
      msg = 'a quota is a limit on its own period and no other' ).

  ENDMETHOD.

  METHOD another_material_is_apart.

    given_quota( 100 ).

    DATA(lt_line) = list( VALUE #( ( recorded( iv_confirmed = 30
                                               iv_matnr     = c_other ) ) ) ).

    cl_abap_unit_assert=>assert_false( says( it_line = lt_line
                                             iv_text = `30.000` ) ).

  ENDMETHOD.

  METHOD the_house_rule_is_per_customer.

    given_quota( iv_quantity = 100
                 iv_kunnr    = '' ).

    DATA(lt_line) = list( VALUE #( ( recorded( 30 ) )
                                   ( recorded( iv_confirmed = 40
                                               iv_kunnr     = c_small ) ) ) ).

    " a row naming no customer is a limit each of them runs into separately,
    " so it becomes one line per customer rather than one line of seventy: the
    " title, the heading and the two of them
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_line )
      exp = 4 ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `QTLBIG` ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `QTLSMALL` ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `40.000` ) ).

  ENDMETHOD.

  METHOD a_closed_plant_is_refused.

    TRY.
        list( it_recorded = VALUE #( )
              iv_refuse   = abap_true ).
        cl_abap_unit_assert=>fail( 'what a plant agreed is the plant''s business' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
