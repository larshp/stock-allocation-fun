CLASS ltcl_repl_source_repo DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_candidate_records FOR TESTING RAISING cx_static_check.
    METHODS tests_pir_service_sql FOR TESTING RAISING cx_static_check.
    METHODS reads_outline_agreements FOR TESTING RAISING cx_static_check.
    METHODS tests_outline_service_sql FOR TESTING
      RAISING cx_static_check.
    METHODS reads_source_contexts FOR TESTING RAISING cx_static_check.
    METHODS reads_quota_arrangements FOR TESTING RAISING cx_static_check.
    METHODS reads_quota_roundings FOR TESTING RAISING cx_static_check.
    METHODS reads_usage_rules FOR TESTING RAISING cx_static_check.
    METHODS skips_empty_requests FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_repl_source_repo IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    DATA lt_eina TYPE STANDARD TABLE OF eina WITH EMPTY KEY.
    DATA lt_eine TYPE STANDARD TABLE OF eine WITH EMPTY KEY.
    DATA lt_eord TYPE STANDARD TABLE OF eord WITH EMPTY KEY.
    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.
    DATA lt_marc TYPE STANDARD TABLE OF marc WITH EMPTY KEY.
    DATA lt_equk TYPE STANDARD TABLE OF equk WITH EMPTY KEY.
    DATA lt_equp TYPE STANDARD TABLE OF equp WITH EMPTY KEY.
    DATA lt_rdpr TYPE STANDARD TABLE OF rdpr WITH EMPTY KEY.
    DATA lt_tmq2 TYPE STANDARD TABLE OF tmq2 WITH EMPTY KEY.

    APPEND 'EINA' TO lt_tables.
    APPEND 'EINE' TO lt_tables.
    APPEND 'EORD' TO lt_tables.
    APPEND 'EKKO' TO lt_tables.
    APPEND 'EKPO' TO lt_tables.
    APPEND 'MARC' TO lt_tables.
    APPEND 'EQUK' TO lt_tables.
    APPEND 'EQUP' TO lt_tables.
    APPEND 'RDPR' TO lt_tables.
    APPEND 'TMQ2' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).

    APPEND VALUE #(
      infnr = 'INFO-1'
      matnr = 'MAT-1'
      lifnr = 'VEND-1'
      esokz = '0'
      lifab = '20260101'
      lifbi = '20261231'
      meins = 'EA'
      lmein = 'EA'
      umrez = 1
      umren = 1 ) TO lt_eina.
    APPEND VALUE #(
      infnr = 'INFO-2'
      matnr = 'MAT-2'
      lifnr = 'VEND-2'
      esokz = '0'
      lifab = '20260101'
      lifbi = '20261231'
      meins = 'KG'
      lmein = 'KG'
      umrez = 1
      umren = 1 ) TO lt_eina.
    APPEND VALUE #(
      infnr = 'INFO-3'
      matnr = 'MAT-1'
      lifnr = 'VEND-1'
      esokz = '0'
      lifab = '20260101'
      lifbi = '20261231'
      meins = 'EA'
      lmein = 'EA'
      umrez = 1
      umren = 1
      loekz = 'X' ) TO lt_eina.
    APPEND VALUE #(
      infnr = 'INFO-4'
      matnr = 'MAT-1'
      lifnr = 'VEND-1'
      esokz = '0'
      lifab = '20260101'
      lifbi = '20261231'
      meins = 'EA'
      lmein = 'EA'
      umrez = 1
      umren = 1 ) TO lt_eina.
    APPEND VALUE #(
      infnr = 'INFO-5'
      matnr = 'MAT-1'
      lifnr = 'VEND-5'
      esokz = '0'
      lifab = '20260101'
      lifbi = '20261231'
      meins = 'EA'
      lmein = 'EA'
      umrez = 1
      umren = 1 ) TO lt_eina.

    APPEND VALUE #(
      infnr      = 'INFO-1'
      ekorg      = 'P001'
      werks      = '1000'
      aplfz      = 4
      aut_source = 'X'
      minbm      = '2.000'
      bstma      = '20.000' ) TO lt_eine.
    APPEND VALUE #(
      infnr = 'INFO-1'
      ekorg = 'P001'
      werks = '2000'
      aplfz = 6
      minbm = '3.000'
      bstma = '30.000' ) TO lt_eine.
    APPEND VALUE #(
      infnr = 'INFO-1'
      ekorg = 'P001'
      aplfz = 3
      minbm = '1.000'
      bstma = '15.000' ) TO lt_eine.
    APPEND VALUE #(
      infnr = 'INFO-1'
      ekorg = 'P002'
      werks = '1000'
      aplfz = 9 ) TO lt_eine.
    APPEND VALUE #(
      infnr = 'INFO-2'
      ekorg = 'P001'
      werks = '1000'
      aplfz = 5
      minbm = '4.000'
      bstma = '40.000' ) TO lt_eine.
    APPEND VALUE #(
      infnr      = 'INFO-2'
      ekorg      = 'P001'
      werks      = '2000'
      aplfz      = 7
      aut_source = space ) TO lt_eine.
    APPEND VALUE #(
      infnr = 'INFO-3'
      ekorg = 'P001'
      werks = '1000'
      aplfz = 2 ) TO lt_eine.
    APPEND VALUE #(
      infnr = 'INFO-4'
      ekorg = 'P001'
      werks = '1000'
      aplfz = 2
      loekz = 'X' ) TO lt_eine.
    APPEND VALUE #(
      infnr      = 'INFO-5'
      ekorg      = 'P001'
      werks      = '1000'
      aplfz      = 2
      aut_source = 'X' ) TO lt_eine.

    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00001'
      lifnr = 'VEND-1'
      ekorg = 'P001'
      ebeln = 'AG-1'
      ebelp = '00010'
      vdatu = '20261005'
      bdatu = '20261005'
      flifn = 'X'
      autet = '1' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00002'
      lifnr = 'VEND-2'
      ekorg = 'P001'
      ebeln = 'AG-2'
      ebelp = '00020'
      vdatu = '20260101'
      bdatu = '20261231' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00003'
      lifnr = 'VEND-3'
      ekorg = 'P001'
      ebeln = 'AG-3'
      ebelp = '00030'
      vdatu = '20260101'
      bdatu = '20261231' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00004'
      lifnr = 'VEND-4'
      ekorg = 'P002'
      ebeln = 'AG-4'
      ebelp = '00040'
      vdatu = '20260101'
      bdatu = '20261231' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '2000'
      zeord = '00005'
      lifnr = 'VEND-5'
      ekorg = 'P001'
      ebeln = 'AG-5'
      ebelp = '00050' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00007'
      lifnr = 'VEND-7'
      ekorg = 'P001'
      ebeln = 'AG-6'
      ebelp = '00060'
      vdatu = '20260101'
      bdatu = '20261231'
      notkz = 'X' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00008'
      lifnr = 'VEND-8'
      ekorg = 'P001'
      ebeln = 'AG-7'
      ebelp = '00070'
      vdatu = '20260101'
      bdatu = '20261231' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00009'
      lifnr = 'VEND-9'
      ekorg = 'P001'
      ebeln = 'AG-8'
      ebelp = '00080'
      vdatu = '20260101'
      bdatu = '20261231' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00010'
      lifnr = 'VEND-10'
      ekorg = 'P001'
      ebeln = 'AG-9'
      ebelp = '00090'
      vdatu = '20260101'
      bdatu = '20261231' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00011'
      lifnr = 'VEND-11'
      ekorg = 'P001'
      ebeln = 'AG-10'
      ebelp = '00010'
      vdatu = '20260101'
      bdatu = '20261231' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00012'
      lifnr = 'VEND-12'
      ekorg = 'P001'
      ebeln = 'AG-11'
      ebelp = '00011'
      vdatu = '20261006'
      bdatu = '20261231' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00013'
      lifnr = 'VEND-13'
      ekorg = 'P001'
      ebeln = 'AG-12'
      ebelp = '00012'
      vdatu = '20260101'
      bdatu = '20261231' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00014'
      lifnr = 'VEND-1'
      ekorg = 'P001'
      vdatu = '20261005'
      bdatu = '20261005'
      flifn = 'X'
      autet = '1' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      zeord = '00015'
      lifnr = 'VEND-5'
      ekorg = 'P001'
      vdatu = '20261005'
      bdatu = '20261005'
      notkz = 'X' ) TO lt_eord.
    APPEND VALUE #(
      matnr = 'MAT-2'
      werks = '2000'
      zeord = '00006'
      lifnr = 'VEND-6'
      ekorg = 'P001' ) TO lt_eord.

    APPEND VALUE #(
      ebeln = 'AG-1'
      bstyp = 'K'
      lifnr = 'VEND-1'
      ekorg = 'P001'
      kdatb = '20261005'
      kdate = '20261005' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'AG-2'
      bstyp = 'K'
      lifnr = 'VEND-2'
      ekorg = 'P001'
      kdatb = '20260101'
      kdate = '20261231' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'AG-11'
      bstyp = 'K'
      lifnr = 'VEND-12'
      ekorg = 'P001'
      kdatb = '20260101'
      kdate = '20261231' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'AG-12'
      bstyp = 'K'
      lifnr = 'VEND-13'
      ekorg = 'P001'
      kdatb = '20261006'
      kdate = '20261231' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'AG-3'
      bstyp = 'K'
      lifnr = 'VEND-3'
      ekorg = 'P001' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'AG-4'
      bstyp = 'K'
      lifnr = 'VEND-4'
      ekorg = 'P002' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'AG-5'
      bstyp = 'K'
      lifnr = 'VEND-5'
      ekorg = 'P001' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'AG-6'
      bstyp = 'K'
      lifnr = 'VEND-7'
      ekorg = 'P001'
      kdatb = '20260101'
      kdate = '20261231' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'AG-7'
      bstyp = 'K'
      lifnr = 'VEND-8'
      ekorg = 'P001'
      kdatb = '20260101'
      kdate = '20261231'
      loekz = 'X' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'AG-8'
      bstyp = 'K'
      lifnr = 'VEND-9'
      ekorg = 'P001'
      kdatb = '20260101'
      kdate = '20261231' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'AG-9'
      bstyp = 'K'
      lifnr = 'VEND-10'
      ekorg = 'P001'
      kdatb = '20260101'
      kdate = '20261231' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'AG-10'
      bstyp = 'L'
      lifnr = 'VEND-11'
      ekorg = 'P001'
      kdatb = '20260101'
      kdate = '20261231' ) TO lt_ekko.

    APPEND VALUE #(
      ebeln = 'AG-1'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      elikz = space ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'AG-2'
      ebelp = '00020'
      matnr = 'MAT-1'
      elikz = space ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'AG-3'
      ebelp = '00030'
      matnr = 'MAT-1'
      werks = '2000' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'AG-4'
      ebelp = '00040'
      matnr = 'MAT-1'
      werks = '1000' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'AG-5'
      ebelp = '00050'
      matnr = 'MAT-1'
      werks = '2000' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'AG-6'
      ebelp = '00060'
      matnr = 'MAT-1'
      werks = '1000' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'AG-7'
      ebelp = '00070'
      matnr = 'MAT-1'
      werks = '1000' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'AG-8'
      ebelp = '00080'
      matnr = 'MAT-1'
      werks = '1000'
      elikz = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'AG-9'
      ebelp = '00090'
      matnr = 'MAT-1'
      werks = '1000'
      loekz = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'AG-10'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'AG-11'
      ebelp = '00011'
      matnr = 'MAT-1'
      werks = '1000' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'AG-12'
      ebelp = '00012'
      matnr = 'MAT-1'
      werks = '1000' ) TO lt_ekpo.

    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      kordb = 'X'
      usequ = '1' ) TO lt_marc.
    APPEND VALUE #(
      matnr = 'MAT-2'
      werks = '2000'
      usequ = '2' ) TO lt_marc.

    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      bdatu = '20261231'
      vdatu = '20260101'
      qunum = 'QUOTA-1'
      scmng = '10.000' ) TO lt_equk.
    APPEND VALUE #(
      matnr = 'MAT-2'
      werks = '2000'
      bdatu = '20261231'
      vdatu = '20260101'
      qunum = 'QUOTA-2'
      scmng = '2.000' ) TO lt_equk.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '2000'
      bdatu = '20261231'
      vdatu = '20260101'
      qunum = 'QUOTA-3'
      scmng = '5.000' ) TO lt_equk.

    APPEND VALUE #(
      qunum = 'QUOTA-1'
      qupos = '001'
      beskz = 'F'
      lifnr = 'VEND-1'
      quote = 70
      qubmg = '100.000'
      qumng = '25.000'
      preih = '01'
      minls = '2.000'
      maxls = '50.000'
      kzein = 'X'
      maxmg = '60.000'
      rdprf = 'R001' ) TO lt_equp.
    APPEND VALUE #(
      qunum = 'QUOTA-1'
      qupos = '002'
      beskz = 'F'
      lifnr = 'VEND-2'
      quote = 30
      qubmg = '100.000'
      qumng = '10.000'
      preih = '02'
      minls = '1.000'
      maxls = '40.000' ) TO lt_equp.
    APPEND VALUE #(
      qunum = 'QUOTA-2'
      qupos = '001'
      beskz = 'E'
      lifnr = 'VEND-3'
      quote = 100
      qubmg = '50.000'
      qumng = '5.000' ) TO lt_equp.
    APPEND VALUE #(
      qunum = 'QUOTA-3'
      qupos = '001'
      beskz = 'F'
      lifnr = 'VEND-4'
      quote = 100
      qubmg = '50.000'
      qumng = '5.000' ) TO lt_equp.

    APPEND VALUE #(
      werks = '1000'
      rdprf = 'R001'
      rdzae = '000001'
      bdmng = '10.000'
      vormg = '2.000' ) TO lt_rdpr.
    APPEND VALUE #(
      werks = '1000'
      rdprf = 'R001'
      rdzae = '000002'
      bdmng = '20.000'
      vormg = '5.000' ) TO lt_rdpr.
    APPEND VALUE #(
      werks = '1000'
      rdprf = 'R002'
      rdzae = '000001'
      bdmng = '10.000'
      vormg = '1.000' ) TO lt_rdpr.
    APPEND VALUE #(
      werks = '2000'
      rdprf = 'R001'
      rdzae = '000001'
      bdmng = '10.000'
      vormg = '3.000' ) TO lt_rdpr.

    APPEND VALUE #(
      usequ = '1'
      qbest = 'X'
      qlpet = 'X'
      qplaf = 'X'
      qbanf = 'X'
      qdisp = 'X'
      qfauf = 'X'
      qfir  = 'X' ) TO lt_tmq2.
    APPEND VALUE #(
      usequ = '2'
      qbest = 'X'
      qdisp = 'X' ) TO lt_tmq2.
    APPEND VALUE #(
      usequ = '3'
      qfir  = 'X' ) TO lt_tmq2.

    mo_environment->insert_test_data( lt_eina ).
    mo_environment->insert_test_data( lt_eine ).
    mo_environment->insert_test_data( lt_eord ).
    mo_environment->insert_test_data( lt_ekko ).
    mo_environment->insert_test_data( lt_ekpo ).
    mo_environment->insert_test_data( lt_marc ).
    mo_environment->insert_test_data( lt_equk ).
    mo_environment->insert_test_data( lt_equp ).
    mo_environment->insert_test_data( lt_rdpr ).
    mo_environment->insert_test_data( lt_tmq2 ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD reads_candidate_records.
    DATA(lo_cut) = NEW zcl_repl_source_repo( ).
    DATA(lt_candidates) = lo_cut->zif_repl_source_repo~get_candidates_bulk(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000' purchasing_org = 'P001'
          delivery_date = '20261001' )
        ( material = 'MAT-1' plant = '2000' purchasing_org = 'P001'
          delivery_date = '20261002' )
        ( material = 'MAT-1' plant = '1000' purchasing_org = 'P001'
          delivery_date = '20261003' )
        ( material = 'MAT-1' plant = '1000' purchasing_org = 'P002'
          delivery_date = '20261001' )
        ( material = 'MAT-2' plant = '1000' purchasing_org = 'P001'
          delivery_date = '20261001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 8
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lt_candidates[ record_plant = '1000' ]-planned_delivery_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 6
      act = lt_candidates[ record_plant = '2000' ]-planned_delivery_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lt_candidates[ record_plant = space ]-planned_delivery_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 9
      act = lt_candidates[ purchasing_org = 'P002' ]-planned_delivery_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'VEND-2'
      act = lt_candidates[ material = 'MAT-2' ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_candidates[ info_record = 'INFO-3' ]-general_deletion_indicator ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_candidates[ info_record = 'INFO-4' ]-purchasing_deletion_indicator ).
  ENDMETHOD.

  METHOD tests_pir_service_sql.
    DATA(lo_repository) = NEW zcl_repl_source_repo( ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = 'P001'
          delivery_date  = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'INFO-1'
      act = lt_candidates[ record_plant = '1000' ]-info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'INFO-1'
      act = lt_candidates[ record_plant = space ]-info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ record_plant = '1000' ]-source_list_required ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ record_plant = '1000' ]-is_source_listed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ record_plant = '1000' ]-is_fixed_source ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ record_plant = '1000' ]-is_mrp_relevant ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ record_plant = '1000' ]-is_auto_source_relevant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00014'
      act = lt_candidates[ record_plant = '1000' ]-source_list_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ record_plant = space ]-is_auto_source_relevant ).

    lt_candidates = lo_cut->get_valid_pir_candidates(
      it_requests            = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = 'P001'
          delivery_date  = '20261005' ) )
      iv_require_auto_source = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lt_candidates[ 1 ]-record_plant ).

    lt_candidates = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = 'P001'
          delivery_date  = '20261006' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_candidates ) ).

    lt_candidates = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material       = 'MAT-2'
          plant          = '2000'
          purchasing_org = 'P001'
          delivery_date  = '20261005' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'VEND-2'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ 1 ]-source_list_required ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ 1 ]-is_source_listed ).

    lt_candidates = lo_cut->get_valid_pir_candidates(
      it_requests              = VALUE #(
        ( material       = 'MAT-2'
          plant          = '2000'
          purchasing_org = 'P001'
          delivery_date  = '20261005' ) )
      iv_require_source_listed = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_candidates ) ).
  ENDMETHOD.

  METHOD reads_outline_agreements.
    DATA(lo_cut) = NEW zcl_repl_source_repo( ).
    DATA(lt_agreements) = lo_cut->zif_repl_source_repo~get_outline_agreements_bulk(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000' purchasing_org = 'P001' )
        ( material = 'MAT-1' plant = '1000' purchasing_org = 'P001' )
        ( material = 'MAT-1' plant = '1000' purchasing_org = 'P002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lines( lt_agreements ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'VEND-1'
      act = lt_agreements[ purchasing_document = 'AG-1' ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'P001'
      act = lt_agreements[ purchasing_document = 'AG-1' ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'K'
      act = lt_agreements[ purchasing_document = 'AG-1' ]-document_category ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_agreements[ purchasing_document = 'AG-1' ]-source_list_valid_from ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_agreements[ purchasing_document = 'AG-1' ]-source_list_valid_to ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_agreements[ purchasing_document = 'AG-1' ]-agreement_valid_from ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_agreements[ purchasing_document = 'AG-1' ]-agreement_valid_to ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lt_agreements[ purchasing_document = 'AG-2' ]-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'P002'
      act = lt_agreements[ purchasing_document = 'AG-4' ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_agreements[ purchasing_document = 'AG-6' ]-source_list_blocked ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_agreements[ purchasing_document = 'AG-7' ]-header_deletion_indicator ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_agreements[ purchasing_document = 'AG-8' ]-item_delivery_complete ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_agreements[ purchasing_document = 'AG-9' ]-item_deletion_indicator ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'L'
      act = lt_agreements[ purchasing_document = 'AG-10' ]-document_category ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261006'
      act = lt_agreements[ purchasing_document = 'AG-11' ]-source_list_valid_from ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261006'
      act = lt_agreements[ purchasing_document = 'AG-12' ]-agreement_valid_from ).
  ENDMETHOD.

  METHOD tests_outline_service_sql.
    DATA(lo_repository) = NEW zcl_repl_source_repo( ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).
    DATA(lt_candidates) = lo_cut->get_valid_outline_sources(
      it_requests = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = 'P001'
          delivery_date  = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'AG-1'
      act = lt_candidates[ 1 ]-purchasing_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'K'
      act = lt_candidates[ 1 ]-document_category ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_fixed_source ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_mrp_relevant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'AG-2'
      act = lt_candidates[ 2 ]-purchasing_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ 2 ]-is_fixed_source ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'AG-10'
      act = lt_candidates[ 3 ]-purchasing_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'L'
      act = lt_candidates[ 3 ]-document_category ).
  ENDMETHOD.

  METHOD reads_source_contexts.
    DATA(lo_cut) = NEW zcl_repl_source_repo( ).
    DATA(lt_contexts) = lo_cut->zif_repl_source_repo~get_source_contexts_bulk(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000' )
        ( material = 'MAT-2' plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 16
      act = lines( lt_contexts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_contexts[ material = 'MAT-1'
                         plant = '1000' ]-source_list_required ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lt_contexts[ source_list_record = '00001' ]-quota_arrangement_usage ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'VEND-4'
      act = lt_contexts[ source_list_record = '00004' ]-source_list_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2'
      act = lt_contexts[ source_list_record = '00006' ]-quota_arrangement_usage ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_contexts[ source_list_record = '00015' ]-source_list_blocked ).
  ENDMETHOD.

  METHOD reads_quota_arrangements.
    DATA(lo_cut) = NEW zcl_repl_source_repo( ).
    DATA(lt_arrangements) = lo_cut->zif_repl_source_repo~get_quota_arrangements_bulk(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000' )
        ( material = 'MAT-2' plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_arrangements ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV equk-scmng( '10.000' )
      act = lt_arrangements[ quota_number = 'QUOTA-1'
                             quota_item = '001' ]-minimum_split_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'VEND-2'
      act = lt_arrangements[ quota_number = 'QUOTA-1'
                             quota_item = '002' ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV equp-qubmg( '50.000' )
      act = lt_arrangements[ quota_number = 'QUOTA-2'
                             quota_item = '001' ]-quota_base_quantity ).
  ENDMETHOD.

  METHOD reads_quota_roundings.
    DATA(lo_cut) = NEW zcl_repl_source_repo( ).
    DATA(lt_profiles) = lo_cut->zif_repl_source_repo~get_quota_roundings_bulk(
      it_profile_keys = VALUE #(
        ( plant = '1000' rounding_profile = 'R001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_profiles ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV rdpr-vormg( '2.000' )
      act = lt_profiles[ level_number = '000001' ]-rounding_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV rdpr-bdmng( '20.000' )
      act = lt_profiles[ level_number = '000002' ]-threshold_quantity ).
  ENDMETHOD.

  METHOD reads_usage_rules.
    DATA(lo_cut) = NEW zcl_repl_source_repo( ).
    DATA(lt_rules) = lo_cut->zif_repl_source_repo~get_quota_usage_rules_bulk(
      it_usages = VALUE #( ( quota_usage = '1' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_rules ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_rules[ 1 ]-includes_purchase_orders ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_rules[ 1 ]-includes_purchase_requisitions ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_rules[ 1 ]-includes_invoices ).
  ENDMETHOD.

  METHOD skips_empty_requests.
    DATA(lo_cut) = NEW zcl_repl_source_repo( ).
    DATA(lt_candidates) = lo_cut->zif_repl_source_repo~get_candidates_bulk(
      it_requests = VALUE #( ) ).
    DATA(lt_agreements) = lo_cut->zif_repl_source_repo~get_outline_agreements_bulk(
      it_requests = VALUE #( ) ).
    DATA(lt_contexts) = lo_cut->zif_repl_source_repo~get_source_contexts_bulk(
      it_requests = VALUE #( ) ).
    DATA(lt_arrangements) = lo_cut->zif_repl_source_repo~get_quota_arrangements_bulk(
      it_requests = VALUE #( ) ).
    DATA(lt_profiles) = lo_cut->zif_repl_source_repo~get_quota_roundings_bulk(
      it_profile_keys = VALUE #( ) ).
    DATA(lt_rules) = lo_cut->zif_repl_source_repo~get_quota_usage_rules_bulk(
      it_usages = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_candidates ).
    cl_abap_unit_assert=>assert_initial( act = lt_agreements ).
    cl_abap_unit_assert=>assert_initial( act = lt_contexts ).
    cl_abap_unit_assert=>assert_initial( act = lt_arrangements ).
    cl_abap_unit_assert=>assert_initial( act = lt_profiles ).
    cl_abap_unit_assert=>assert_initial( act = lt_rules ).
  ENDMETHOD.
ENDCLASS.
