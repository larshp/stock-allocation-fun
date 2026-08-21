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


CLASS ltcl_alloc_cfg_check DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9291'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'CFGC-MAT-01'.
    CONSTANTS c_gone  TYPE mard-matnr VALUE 'CFGC-GONE-01'.
    CONSTANTS c_kunnr TYPE vbak-kunnr VALUE 'CFGCCUST'.

    METHODS setup.
    METHODS teardown.

    METHODS given_quota
      IMPORTING
        iv_from     TYPE d DEFAULT '20260101'
        iv_to       TYPE d DEFAULT '20261231'
        iv_quantity TYPE zif_allocation=>ty_quantity DEFAULT 50
        iv_matnr    TYPE zstock_alloc_qta-matnr DEFAULT c_matnr.

    METHODS given_substitute
      IMPORTING
        iv_substitute TYPE zstock_alloc_sub-substitute
        iv_factor     TYPE zif_allocation=>ty_quantity DEFAULT 1.

    METHODS given_source
      IMPORTING
        iv_class TYPE zstock_alloc_ext-classname
        iv_kind  TYPE zstock_alloc_ext-kind.

    METHODS checked
      IMPORTING
        iv_refuse      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_cfg_check=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS says
      IMPORTING
        it_line       TYPE zcl_alloc_cfg_check=>ty_line_tab
        iv_text       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS a_tidy_plant_says_so FOR TESTING RAISING cx_static_check.
    METHODS a_backwards_period_shows FOR TESTING RAISING cx_static_check.
    METHODS a_material_that_is_gone FOR TESTING RAISING cx_static_check.
    METHODS a_substitute_for_itself FOR TESTING RAISING cx_static_check.
    METHODS a_source_nobody_wrote FOR TESTING RAISING cx_static_check.
    METHODS a_source_of_the_wrong_kind FOR TESTING RAISING cx_static_check.
    METHODS a_closed_plant_is_refused FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cfg_check IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara  TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_t001w TYPE STANDARD TABLE OF t001w WITH EMPTY KEY.

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = 'PC' ) ).
    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_t001w = VALUE #(
      ( mandt = sy-mandt werks = c_werks name1 = 'Check plant' fabkl = '01' ) ).
    INSERT t001w FROM TABLE @lt_t001w.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM t001w WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM zstock_alloc_qta WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM zstock_alloc_sub WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM zstock_alloc_ext WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_quota.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_qta WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt     = sy-mandt
        werks     = c_werks
        matnr     = iv_matnr
        kunnr     = c_kunnr
        date_from = iv_from
        date_to   = iv_to
        quantity  = iv_quantity ) ).

    INSERT zstock_alloc_qta FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD given_substitute.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_sub WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        werks      = c_werks
        matnr      = c_matnr
        substitute = iv_substitute
        factor     = iv_factor ) ).

    INSERT zstock_alloc_sub FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD given_source.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_ext WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt     = sy-mandt
        werks     = c_werks
        kind      = iv_kind
        classname = iv_class ) ).

    INSERT zstock_alloc_ext FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD checked.

    rt_line = NEW zcl_alloc_cfg_check( NEW lcl_authority_double( iv_refuse ) )->run( c_werks ).

  ENDMETHOD.

  METHOD says.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CS iv_text.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD a_tidy_plant_says_so.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.

    given_quota( ).
    given_substitute( c_matnr && '-X' ).

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr && '-X' mtart = 'FERT' meins = 'PC' ) ).
    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_subrc( ).

    DATA(lt_line) = checked( ).

    DELETE FROM mara WHERE matnr = @( CONV mara-matnr( c_matnr && '-X' ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `Nothing to correct` )
      msg = 'a check that finds something in a tidy plant is a check nobody runs twice' ).

  ENDMETHOD.

  METHOD a_backwards_period_shows.

    given_quota( iv_from = '20261231'
                 iv_to   = '20260101' ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = checked( )
                  iv_text = `runs backwards` )
      msg = 'a quota that never applies looks exactly like one that does' ).

  ENDMETHOD.

  METHOD a_material_that_is_gone.

    given_quota( iv_matnr = c_gone ).

    cl_abap_unit_assert=>assert_true( says( it_line = checked( )
                                            iv_text = `no such material` ) ).

  ENDMETHOD.

  METHOD a_substitute_for_itself.

    given_substitute( c_matnr ).

    cl_abap_unit_assert=>assert_true( says( it_line = checked( )
                                            iv_text = `stands in for itself` ) ).

  ENDMETHOD.

  METHOD a_source_nobody_wrote.

    given_source( iv_class = 'ZCL_NOBODY_WROTE_THIS'
                  iv_kind  = zcl_alloc_extensions=>c_supply ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = checked( )
                  iv_text = `cannot be created` )
      msg = 'a class nobody transported fails the whole plant on its first material' ).

  ENDMETHOD.

  METHOD a_source_of_the_wrong_kind.

    " a real class, creatable, and not a supply reader at all
    given_source( iv_class = 'ZCL_ALLOC_LOG_NONE'
                  iv_kind  = zcl_alloc_extensions=>c_supply ).

    cl_abap_unit_assert=>assert_true( says( it_line = checked( )
                                            iv_text = `is not a reader of kind` ) ).

  ENDMETHOD.

  METHOD a_closed_plant_is_refused.

    TRY.
        checked( abap_true ).
        cl_abap_unit_assert=>fail( 'what a plant has configured is the plant''s business' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
