CLASS ltcl_run_id_uuid DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zif_run_id_supplier.

    METHODS setup.
    METHODS fills_the_whole_field FOR TESTING RAISING cx_static_check.
    METHODS ids_are_unique FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_run_id_uuid IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_run_id_uuid( ).
  ENDMETHOD.

  METHOD fills_the_whole_field.

    DATA(lv_run_id) = mo_cut->next( ).

    cl_abap_unit_assert=>assert_equals(
      act = strlen( lv_run_id )
      exp = 22
      msg = 'the run id must fill ZSTOCK_ALLOC_RES-RUN_ID exactly' ).

  ENDMETHOD.

  METHOD ids_are_unique.

    cl_abap_unit_assert=>assert_differs(
      act = mo_cut->next( )
      exp = mo_cut->next( )
      msg = 'two runs must not end up sharing a result row' ).

  ENDMETHOD.

ENDCLASS.
