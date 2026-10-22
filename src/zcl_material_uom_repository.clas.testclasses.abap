CLASS ltcl_material_uom_repository DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_base_unit FOR TESTING RAISING cx_static_check.
    METHODS reads_base_unit_missing FOR TESTING RAISING cx_static_check.
    METHODS reads_alt_unit_ratio FOR TESTING RAISING cx_static_check.
    METHODS reads_alt_unit_ratio_missing FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_material_uom_repository IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    APPEND 'MARA' TO lt_tables.
    APPEND 'MARM' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD reads_base_unit.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lv_material TYPE mara-matnr VALUE 'MAT-1'.
    APPEND VALUE #(
      matnr = 'MAT-1'
      meins = 'EA' ) TO lt_mara.
    mo_environment->insert_test_data( lt_mara ).

    DATA(lo_repository) = NEW zcl_material_uom_repository( ).
    DATA(lv_base_unit) =
      lo_repository->zif_material_uom_repository~get_base_unit(
        iv_material = lv_material ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mara-meins( 'EA' )
      act = lv_base_unit ).
  ENDMETHOD.

  METHOD reads_base_unit_missing.
    DATA lv_material TYPE mara-matnr VALUE 'UNKNOWN'.
    DATA(lo_repository) = NEW zcl_material_uom_repository( ).

    DATA(lv_base_unit) =
      lo_repository->zif_material_uom_repository~get_base_unit(
        iv_material = lv_material ).

    cl_abap_unit_assert=>assert_initial(
      act = lv_base_unit ).
  ENDMETHOD.

  METHOD reads_alt_unit_ratio.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.
    DATA lv_material TYPE marm-matnr VALUE 'MAT-1'.
    DATA lv_alternative_unit TYPE marm-meinh VALUE 'BOX'.
    APPEND VALUE #(
      matnr = 'MAT-1'
      meinh = 'BOX'
      umrez = 12
      umren = 1 ) TO lt_marm.
    APPEND VALUE #(
      matnr = 'MAT-1'
      meinh = 'PAL'
      umrez = 120
      umren = 1 ) TO lt_marm.
    mo_environment->insert_test_data( lt_marm ).

    DATA(lo_repository) = NEW zcl_material_uom_repository( ).
    DATA(ls_ratio) =
      lo_repository->zif_material_uom_repository~get_alt_unit_ratio(
        iv_material         = lv_material
        iv_alternative_unit = lv_alternative_unit ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV marm-umrez( 12 )
      act = ls_ratio-numerator ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marm-umren( 1 )
      act = ls_ratio-denominator ).
  ENDMETHOD.

  METHOD reads_alt_unit_ratio_missing.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.
    DATA lv_material TYPE marm-matnr VALUE 'MAT-1'.
    DATA lv_alternative_unit TYPE marm-meinh VALUE 'PAL'.
    APPEND VALUE #(
      matnr = 'MAT-1'
      meinh = 'BOX'
      umrez = 12
      umren = 1 ) TO lt_marm.
    mo_environment->insert_test_data( lt_marm ).

    DATA(lo_repository) = NEW zcl_material_uom_repository( ).
    DATA(ls_ratio) =
      lo_repository->zif_material_uom_repository~get_alt_unit_ratio(
        iv_material         = lv_material
        iv_alternative_unit = lv_alternative_unit ).

    cl_abap_unit_assert=>assert_initial(
      act = ls_ratio ).
  ENDMETHOD.
ENDCLASS.
