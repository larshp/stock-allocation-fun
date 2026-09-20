CLASS ltcl_alloc_extensions DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '9601'.
    CONSTANTS c_other TYPE mard-werks VALUE '9602'.

    METHODS teardown.

    METHODS given_source
      IMPORTING
        iv_kind  TYPE zstock_alloc_ext-kind
        iv_class TYPE zstock_alloc_ext-classname
        iv_werks TYPE zstock_alloc_ext-werks DEFAULT c_werks.

    METHODS a_configured_source_is_there FOR TESTING.
    METHODS a_source_may_be_everywhere FOR TESTING.
    METHODS another_plant_is_not_read FOR TESTING.
    METHODS demand_and_supply_are_apart FOR TESTING.
    METHODS a_class_is_created FOR TESTING RAISING cx_static_check.
    METHODS a_missing_class_is_refused FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_extensions IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM zstock_alloc_ext WHERE classname LIKE 'ZCL_%'.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_source.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_ext WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt     = sy-mandt
        werks     = iv_werks
        kind      = iv_kind
        classname = iv_class ) ).

    INSERT zstock_alloc_ext FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'extension fixture could not be inserted' ).

  ENDMETHOD.

  METHOD a_configured_source_is_there.

    given_source(
      iv_kind  = zcl_alloc_extensions=>c_supply
      iv_class = 'ZCL_SUPPLY_ON_HAND' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( zcl_alloc_extensions=>classes_of(
        iv_werks = c_werks
        iv_kind  = zcl_alloc_extensions=>c_supply ) )
      exp = 1
      msg = 'a class named in Customizing joins the sources the run reads' ).

  ENDMETHOD.

  METHOD a_source_may_be_everywhere.

    given_source(
      iv_kind  = zcl_alloc_extensions=>c_supply
      iv_class = 'ZCL_SUPPLY_ON_HAND'
      iv_werks = '' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( zcl_alloc_extensions=>classes_of(
        iv_werks = c_werks
        iv_kind  = zcl_alloc_extensions=>c_supply ) )
      exp = 1
      msg = 'a source written for the business is not written for one plant' ).

  ENDMETHOD.

  METHOD another_plant_is_not_read.

    given_source(
      iv_kind  = zcl_alloc_extensions=>c_supply
      iv_class = 'ZCL_SUPPLY_ON_HAND'
      iv_werks = c_other ).

    cl_abap_unit_assert=>assert_initial(
      act = zcl_alloc_extensions=>classes_of(
        iv_werks = c_werks
        iv_kind  = zcl_alloc_extensions=>c_supply )
      msg = 'and one written for another plant stays there' ).

  ENDMETHOD.

  METHOD demand_and_supply_are_apart.

    given_source(
      iv_kind  = zcl_alloc_extensions=>c_demand
      iv_class = 'ZCL_SO_DEMAND_READER' ).

    cl_abap_unit_assert=>assert_initial(
      act = zcl_alloc_extensions=>classes_of(
        iv_werks = c_werks
        iv_kind  = zcl_alloc_extensions=>c_supply )
      msg = 'a demand source is not offered to the supply side' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( zcl_alloc_extensions=>classes_of(
        iv_werks = c_werks
        iv_kind  = zcl_alloc_extensions=>c_demand ) )
      exp = 1 ).

  ENDMETHOD.

  METHOD a_class_is_created.

    cl_abap_unit_assert=>assert_bound(
      act = zcl_alloc_extensions=>make( 'ZCL_ALLOC_LOG_NONE' )
      msg = 'a class that exists and can be created, is' ).

  ENDMETHOD.

  METHOD a_missing_class_is_refused.

    TRY.
        zcl_alloc_extensions=>make( 'ZCL_NO_SUCH_CLASS_AT_ALL' ).
        cl_abap_unit_assert=>fail( 'a class name somebody typed can be a class name nobody wrote' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
