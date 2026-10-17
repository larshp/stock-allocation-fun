CLASS ltcl_marc_repl_policy_repo DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_policy_dependencies FOR TESTING RAISING cx_static_check.
    METHODS reads_rounding_profiles FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_marc_repl_policy_repo IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    APPEND 'MARC' TO lt_tables.
    APPEND 'MARA' TO lt_tables.
    APPEND 'T001W' TO lt_tables.
    APPEND 'T399D' TO lt_tables.
    APPEND 'RDPR' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD reads_policy_dependencies.
    DATA lt_marc TYPE STANDARD TABLE OF marc WITH EMPTY KEY.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_t001w TYPE STANDARD TABLE OF t001w WITH EMPTY KEY.
    DATA lt_t399d TYPE STANDARD TABLE OF t399d WITH EMPTY KEY.

    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      disls = 'FX'
      mrppp = 'P01'
      beskz = 'F'
      sobsl = '30'
      plifz = 4
      webaz = 2
      bstmi = '2.000'
      bstma = '90.000'
      mabst = '150.000'
      bstfe = '5.000'
      bstrf = '3.000'
      rdprf = 'R001' ) TO lt_marc.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '2000'
      disls = 'EX'
      beskz = 'E'
      plifz = 7
      bstmi = '1.000' ) TO lt_marc.
    APPEND VALUE #(
      matnr = 'MAT-2'
      werks = '1000'
      disls = 'EX' ) TO lt_marc.
    APPEND VALUE #(
      matnr = 'MAT-1'
      meins = 'EA' ) TO lt_mara.
    APPEND VALUE #(
      werks = '1000'
      fabkl = '01' ) TO lt_t001w.
    APPEND VALUE #(
      werks = '1000'
      bzteK = '03' ) TO lt_t399d.

    mo_environment->insert_test_data( lt_marc ).
    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_t001w ).
    mo_environment->insert_test_data( lt_t399d ).

    DATA(lo_repository) = NEW zcl_marc_repl_policy_repo( ).
    DATA(lt_policies) =
      lo_repository->zif_replenishment_policy_repo~get_policies_bulk(
        it_material_plants = VALUE #(
          ( material = 'MAT-1' plant = '1000' )
          ( material = 'MAT-1' plant = '2000' )
          ( material = 'MAT-2' plant = '1000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_policies ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-disls( 'FX' )
      act = lt_policies[ material = 'MAT-1' plant = '1000' ]-lot_size_procedure ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mara-meins( 'EA' )
      act = lt_policies[ material = 'MAT-1' plant = '1000' ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV t001w-fabkl( '01' )
      act = lt_policies[ material = 'MAT-1' plant = '1000' ]-factory_calendar_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV t399d-bzteK( '03' )
      act = lt_policies[ material = 'MAT-1' plant = '1000' ]-purchasing_processing_days ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_policies[ material = 'MAT-1' plant = '2000' ]-factory_calendar_id ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_policies[ material = 'MAT-1' plant = '2000' ]-purchasing_processing_days ).
  ENDMETHOD.

  METHOD reads_rounding_profiles.
    DATA lt_rdpr TYPE STANDARD TABLE OF rdpr WITH EMPTY KEY.
    APPEND VALUE #(
      werks = '1000'
      rdprf = 'R001'
      rdzae = '000001'
      bdmng = '10.000'
      vormg = '4.000' ) TO lt_rdpr.
    APPEND VALUE #(
      werks = '1000'
      rdprf = 'R001'
      rdzae = '000002'
      bdmng = '25.000'
      vormg = '8.000' ) TO lt_rdpr.
    APPEND VALUE #(
      werks = '1000'
      rdprf = 'R002'
      rdzae = '000001'
      bdmng = '5.000'
      vormg = '2.000' ) TO lt_rdpr.
    mo_environment->insert_test_data( lt_rdpr ).

    DATA lt_profile_keys TYPE
      zif_replenishment_policy_repo=>ty_rounding_profile_keys.
    INSERT VALUE #( plant = '1000' rounding_profile = 'R001' )
      INTO TABLE lt_profile_keys.
    INSERT VALUE #( plant = '1000' rounding_profile = 'R002' )
      INTO TABLE lt_profile_keys.
    INSERT VALUE #( plant = '2000' rounding_profile = 'R001' )
      INTO TABLE lt_profile_keys.

    DATA(lo_repository) = NEW zcl_marc_repl_policy_repo( ).
    DATA(lt_profiles) =
      lo_repository->zif_replenishment_policy_repo~get_rounding_profiles_bulk(
        it_profile_keys = lt_profile_keys ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_profiles ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV rdpr-bdmng( '25.000' )
      act = lt_profiles[
        plant = '1000'
        rounding_profile = 'R001'
        level_number = '000002' ]-threshold_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV rdpr-vormg( '8.000' )
      act = lt_profiles[
        plant = '1000'
        rounding_profile = 'R001'
        level_number = '000002' ]-rounding_quantity ).
  ENDMETHOD.
ENDCLASS.
