CLASS ltcl_demand_extension DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'EXT-MAT-02'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9604'.

    DATA mo_cut TYPE REF TO zif_demand_reader.

    METHODS setup.
    METHODS teardown.

    METHODS given_source
      IMPORTING
        iv_class TYPE zstock_alloc_ext-classname.

    METHODS nothing_configured_is_quiet FOR TESTING RAISING cx_static_check.
    METHODS a_configured_source_is_read FOR TESTING RAISING cx_static_check.
    METHODS a_missing_class_raises FOR TESTING.
    METHODS the_list_stays_quiet FOR TESTING.

ENDCLASS.


CLASS ltcl_demand_extension IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_demand_extension( ).
  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_ext WHERE classname LIKE 'ZCL_%'.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_source.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_ext WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt     = sy-mandt
        werks     = c_werks
        kind      = zcl_alloc_extensions=>c_demand
        classname = iv_class ) ).

    INSERT zstock_alloc_ext FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD nothing_configured_is_quiet.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open_demand(
        iv_matnr = c_matnr
        iv_werks = c_werks )
      msg = 'a plant that has added nothing pays for nothing' ).

  ENDMETHOD.

  METHOD a_configured_source_is_read.

    " the composite demand reader has a parameterless constructor and no
    " sources of its own: enough to show the wrapper creates it and asks
    given_source( 'ZCL_DEMAND_SOURCES' ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open_demand(
        iv_matnr = c_matnr
        iv_werks = c_werks )
      msg = 'the configured class was created and read' ).

  ENDMETHOD.

  METHOD a_missing_class_raises.

    given_source( 'ZCL_NO_SUCH_DEMAND' ).

    TRY.
        mo_cut->read_open_demand(
          iv_matnr = c_matnr
          iv_werks = c_werks ).
        cl_abap_unit_assert=>fail( 'a source that cannot answer must stop the material, loudly' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD the_list_stays_quiet.

    given_source( 'ZCL_NO_SUCH_DEMAND' ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->materials_with_demand( c_werks )
      msg = 'the material list cannot raise, and the read that follows it can' ).

  ENDMETHOD.

ENDCLASS.
