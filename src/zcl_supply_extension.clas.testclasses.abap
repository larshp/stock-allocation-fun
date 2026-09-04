CLASS ltcl_supply_extension DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'EXT-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9603'.
    CONSTANTS c_other TYPE mard-werks VALUE '9605'.

    DATA mo_cut TYPE REF TO zif_supply_reader.

    METHODS setup.
    METHODS teardown.

    METHODS given_source
      IMPORTING
        iv_class TYPE zstock_alloc_ext-classname
        iv_werks TYPE zstock_alloc_ext-werks DEFAULT c_werks.

    METHODS nothing_configured_is_quiet FOR TESTING RAISING cx_static_check.
    METHODS a_configured_source_is_read FOR TESTING RAISING cx_static_check.
    METHODS another_plant_is_left_alone FOR TESTING RAISING cx_static_check.
    METHODS a_missing_class_raises FOR TESTING.

ENDCLASS.


CLASS ltcl_supply_extension IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_supply_extension( ).
  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_ext WHERE classname LIKE 'ZCL_%'.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_source.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_ext WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt     = sy-mandt
        werks     = iv_werks
        kind      = zcl_alloc_extensions=>c_supply
        classname = iv_class ) ).

    INSERT zstock_alloc_ext FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD nothing_configured_is_quiet.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_supply(
        iv_matnr = c_matnr
        iv_werks = c_werks )
      msg = 'a plant that has added nothing pays for nothing' ).

  ENDMETHOD.

  METHOD a_configured_source_is_read.

    " the composite supply reader has a parameterless constructor and no
    " sources of its own, so what it answers cannot be mistaken for anything
    " else: the point of the test is that the wrapper created it and asked it
    given_source( 'ZCL_SUPPLY_SOURCES' ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_supply(
        iv_matnr = c_matnr
        iv_werks = c_werks )
      msg = 'the configured class was created and read' ).

  ENDMETHOD.

  METHOD another_plant_is_left_alone.

    " a class that cannot be created is the loudest thing a plant can
    " configure, so a plant configured with one and never asked proves that
    " the classes are looked up for the plant being read
    given_source(
      iv_class = 'ZCL_NO_SUCH_SOURCE'
      iv_werks = c_other ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_supply(
        iv_matnr = c_matnr
        iv_werks = c_werks )
      msg = 'what another plant added is another plant''s business' ).

  ENDMETHOD.

  METHOD a_missing_class_raises.

    given_source( 'ZCL_NO_SUCH_SOURCE' ).

    TRY.
        mo_cut->read_supply(
          iv_matnr = c_matnr
          iv_werks = c_werks ).
        cl_abap_unit_assert=>fail( 'allocating on supply that could not be read is the one thing not to do' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
