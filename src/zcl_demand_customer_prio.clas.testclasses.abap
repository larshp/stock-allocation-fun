"! Answers with a fixed demand, whatever it is asked.
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
    rt_matnr = VALUE #( ( 'PRIO-MAT-01' ) ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_demand_customer_prio DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'PRIO-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9401'.
    CONSTANTS c_other TYPE mard-werks VALUE '9402'.
    CONSTANTS c_key   TYPE vbak-kunnr VALUE '0000020001'.
    CONSTANTS c_plain TYPE vbak-kunnr VALUE '0000020002'.

    METHODS teardown.

    METHODS given_rank
      IMPORTING
        iv_kunnr    TYPE zstock_alloc_pri-kunnr
        iv_priority TYPE zstock_alloc_pri-priority
        iv_werks    TYPE zstock_alloc_pri-werks DEFAULT c_werks.

    METHODS demand_of
      IMPORTING
        it_demand        TYPE zif_allocation=>ty_demand_tab
        iv_werks         TYPE mard-werks DEFAULT c_werks
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab
      RAISING
        zcx_allocation.

    METHODS line
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_customer      TYPE vbak-kunnr
        iv_priority      TYPE zif_allocation=>ty_priority DEFAULT '05'
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS a_key_account_moves_up FOR TESTING RAISING cx_static_check.
    METHODS a_plain_customer_is_left FOR TESTING RAISING cx_static_check.
    METHODS a_rule_may_cover_every_plant FOR TESTING RAISING cx_static_check.
    METHODS the_plant_rule_wins FOR TESTING RAISING cx_static_check.
    METHODS another_plant_is_not_read FOR TESTING RAISING cx_static_check.
    METHODS no_customer_is_no_rank FOR TESTING RAISING cx_static_check.
    METHODS the_material_list_is_passed_on FOR TESTING.

ENDCLASS.


CLASS ltcl_demand_customer_prio IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM zstock_alloc_pri WHERE kunnr IN ( @c_key, @c_plain ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_rank.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_pri WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt    = sy-mandt
        werks    = iv_werks
        kunnr    = iv_kunnr
        priority = iv_priority ) ).

    INSERT zstock_alloc_pri FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'customer priority fixture could not be inserted' ).

  ENDMETHOD.

  METHOD line.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = c_matnr
      werks     = c_werks
      quantity  = '10'
      req_date  = '20260301'
      priority  = iv_priority
      customer  = iv_customer ).

  ENDMETHOD.

  METHOD demand_of.

    DATA(lo_cut) = CAST zif_demand_reader( NEW zcl_demand_customer_prio(
      NEW lcl_demand_double( it_demand ) ) ).

    rt_demand = lo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD a_key_account_moves_up.

    given_rank(
      iv_kunnr    = c_key
      iv_priority = '01' ).

    DATA(lt_demand) = demand_of( VALUE #(
      ( line(
          iv_id       = 'D1'
          iv_customer = c_key ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-priority
      exp = '01'
      msg = 'who a business would rather disappoint last is not on the order' ).

  ENDMETHOD.

  METHOD a_plain_customer_is_left.

    given_rank(
      iv_kunnr    = c_key
      iv_priority = '01' ).

    DATA(lt_demand) = demand_of( VALUE #(
      ( line(
          iv_id       = 'D1'
          iv_customer = c_plain ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-priority
      exp = '05'
      msg = 'a customer nobody ranked keeps the priority the order was given' ).

  ENDMETHOD.

  METHOD a_rule_may_cover_every_plant.

    given_rank(
      iv_kunnr    = c_key
      iv_priority = '02'
      iv_werks    = '' ).

    DATA(lt_demand) = demand_of( VALUE #(
      ( line(
          iv_id       = 'D1'
          iv_customer = c_key ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-priority
      exp = '02'
      msg = 'a key account is usually a decision of the business, not of a site' ).

  ENDMETHOD.

  METHOD the_plant_rule_wins.

    given_rank(
      iv_kunnr    = c_key
      iv_priority = '02'
      iv_werks    = '' ).
    given_rank(
      iv_kunnr    = c_key
      iv_priority = '01' ).

    DATA(lt_demand) = demand_of( VALUE #(
      ( line(
          iv_id       = 'D1'
          iv_customer = c_key ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-priority
      exp = '01'
      msg = 'what a site decided for itself beats what it was given without asking' ).

  ENDMETHOD.

  METHOD another_plant_is_not_read.

    given_rank(
      iv_kunnr    = c_key
      iv_priority = '01'
      iv_werks    = c_other ).

    DATA(lt_demand) = demand_of( VALUE #(
      ( line(
          iv_id       = 'D1'
          iv_customer = c_key ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-priority
      exp = '05'
      msg = 'a rule made in one plant does not reach into another' ).

  ENDMETHOD.

  METHOD no_customer_is_no_rank.

    given_rank(
      iv_kunnr    = ''
      iv_priority = '01' ).

    DATA(lt_demand) = demand_of( VALUE #(
      ( line(
          iv_id       = 'D1'
          iv_customer = '' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-priority
      exp = '05'
      msg = 'a stock transport order is not a customer and has no share of this' ).

  ENDMETHOD.

  METHOD the_material_list_is_passed_on.

    DATA(lo_cut) = CAST zif_demand_reader( NEW zcl_demand_customer_prio(
      NEW lcl_demand_double( VALUE #( ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->materials_with_demand( c_werks )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( c_matnr ) )
      msg = 'which materials a run covers does not depend on who is waiting' ).

  ENDMETHOD.

ENDCLASS.
