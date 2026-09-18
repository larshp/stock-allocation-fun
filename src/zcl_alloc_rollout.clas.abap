CLASS zcl_alloc_rollout DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_site,
             site_id TYPE string,
             region  TYPE string,
             users   TYPE i,
           END OF ty_site.
    TYPES ty_site_tt TYPE STANDARD TABLE OF ty_site WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_wave,
             wave_no TYPE i,
             region  TYPE string,
             users   TYPE i,
             sites   TYPE i,
           END OF ty_wave.
    TYPES ty_wave_tt TYPE STANDARD TABLE OF ty_wave WITH DEFAULT KEY.

    METHODS plan
      IMPORTING
        it_sites        TYPE ty_site_tt
        iv_max_users    TYPE i
      RETURNING
        VALUE(rt_waves) TYPE ty_wave_tt.

    METHODS wave_count
      IMPORTING
        it_waves        TYPE ty_wave_tt
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    METHODS fits
      IMPORTING
        is_wave      TYPE ty_wave
        iv_region    TYPE string
        iv_users     TYPE i
        iv_max_users TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_rollout IMPLEMENTATION.

  METHOD fits.
    " A wave stays inside one region and respects the user cap; a single site
    " larger than the cap still gets its own wave so no site is dropped.
    IF is_wave-sites = 0.
      rv_ok = abap_true.
      RETURN.
    ENDIF.

    IF is_wave-region <> iv_region.
      RETURN.
    ENDIF.

    IF iv_max_users > 0 AND is_wave-users + iv_users > iv_max_users.
      RETURN.
    ENDIF.

    rv_ok = abap_true.
  ENDMETHOD.

  METHOD plan.
    DATA lt_sorted TYPE ty_site_tt.
    DATA ls_site   TYPE ty_site.
    DATA ls_wave   TYPE ty_wave.
    DATA lv_hit    TYPE abap_bool.

    lt_sorted = it_sites.

    " Biggest site first inside each region, so the waves fill evenly.
    SORT lt_sorted BY region ASCENDING users DESCENDING.

    LOOP AT lt_sorted INTO ls_site.
      CLEAR lv_hit.

      IF lines( rt_waves ) > 0.
        READ TABLE rt_waves INTO ls_wave INDEX lines( rt_waves ).
        lv_hit = fits( is_wave      = ls_wave
                       iv_region    = ls_site-region
                       iv_users     = ls_site-users
                       iv_max_users = iv_max_users ).
      ENDIF.

      " A new region or a full wave opens the next wave. A site larger than the
      " cap still gets its own wave, so no site is dropped from the plan.
      IF lv_hit = abap_false.
        CLEAR ls_wave.
        ls_wave-wave_no = lines( rt_waves ) + 1.
        ls_wave-region = ls_site-region.
        ls_wave-users = ls_site-users.
        ls_wave-sites = 1.
        APPEND ls_wave TO rt_waves.
        CONTINUE.
      ENDIF.

      ls_wave-users = ls_wave-users + ls_site-users.
      ls_wave-sites = ls_wave-sites + 1.

      " The wave being updated is always the last one, so replacing it keeps
      " the wave numbers in order.
      DELETE rt_waves WHERE wave_no = ls_wave-wave_no.
      APPEND ls_wave TO rt_waves.
    ENDLOOP.
  ENDMETHOD.

  METHOD wave_count.
    rv_count = lines( it_waves ).
  ENDMETHOD.

ENDCLASS.
