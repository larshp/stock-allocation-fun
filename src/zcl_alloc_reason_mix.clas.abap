CLASS zcl_alloc_reason_mix DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Summary wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_mix | <p class="shorttext synchronized">Ready to use summary</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_mix) TYPE REF TO zcl_alloc_reason_mix.

    "! <p class="shorttext synchronized">Wire up the summary</p>
    "!
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_store     TYPE REF TO zif_allocation_store
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">Where a plant's shortfall goes, by reason</p>
    "!
    "! The worklist of feature 48 answers "what is short", one line at a time.
    "! This answers the question a manager asks about the same night: is the
    "! plant short because the goods are not there, or because the plant's own
    "! rationing rules held them back. Those are two different conversations --
    "! one with purchasing, one with the business that set the rules -- and a
    "! list of short lines does not separate them.
    "!
    "! It reads the last recorded run per material and changes nothing.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_dispo       | <p class="shorttext synchronized">MRP controller, every one if empty</p>
    "! @parameter iv_kunnr       | <p class="shorttext synchronized">Customer, every one if empty</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be displayed</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_dispo       TYPE marc-dispo OPTIONAL
        iv_kunnr       TYPE vbak-kunnr OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_why   TYPE i VALUE 34.
    CONSTANTS c_width_count TYPE i VALUE 10.
    CONSTANTS c_width_share TYPE i VALUE 8.

    "! Reading what a run decided, not deciding anything.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    "! Which of the three blocks a reason is counted under.
    TYPES ty_side TYPE c LENGTH 1.

    "! Which conversation a reason belongs to. The whole point of the report is
    "! that these are not the same problem: stock that is not there is somebody
    "! else's to fix, and a line held back by a rule of the plant's own making
    "! is the plant's.
    CONSTANTS:
      BEGIN OF c_side,
        supply TYPE ty_side VALUE 'S',
        rules  TYPE ty_side VALUE 'R',
        other  TYPE ty_side VALUE 'O',
      END OF c_side.

    "! One reason, counted. MATERIALS is how many materials it touched, which
    "! says whether a reason is one bad material or a plant wide policy.
    TYPES:
      BEGIN OF ty_count,
        side      TYPE ty_side,
        reason    TYPE zif_allocation=>ty_reason,
        lines     TYPE i,
        materials TYPE i,
      END OF ty_count.
    TYPES ty_count_tab TYPE STANDARD TABLE OF ty_count WITH EMPTY KEY.

    TYPES ty_matnr_tab TYPE STANDARD TABLE OF mard-matnr WITH EMPTY KEY.

    "! What one run of the report worked out, so that the blocks and the footer
    "! read the same numbers rather than counting twice.
    TYPES:
      BEGIN OF ty_total,
        count     TYPE ty_count_tab,
        answered  TYPE i,
        short     TYPE i,
        materials TYPE i,
      END OF ty_total.

    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS counted
      IMPORTING
        it_recorded     TYPE zif_allocation_store=>ty_recorded_tab
        iv_werks        TYPE mard-werks
        iv_dispo        TYPE marc-dispo
        iv_kunnr        TYPE vbak-kunnr
      RETURNING
        VALUE(rs_total) TYPE ty_total.

    METHODS side_of
      IMPORTING
        iv_reason      TYPE zif_allocation=>ty_reason
      RETURNING
        VALUE(rv_side) TYPE ty_side.

    METHODS block_lines
      IMPORTING
        is_total       TYPE ty_total
        iv_side        TYPE ty_side
        iv_heading     TYPE string
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS format_row
      IMPORTING
        iv_why         TYPE string
        iv_lines       TYPE string
        iv_share       TYPE string
        iv_materials   TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

    METHODS percent
      IMPORTING
        iv_part           TYPE i
        iv_whole          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_reason_mix IMPLEMENTATION.

  METHOD create_default.

    ro_mix = NEW zcl_alloc_reason_mix(
      io_store     = NEW zcl_allocation_store( )
      io_authority = NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_store     = io_store.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    mo_authority->check_plant( iv_werks ).

    DATA(ls_total) = counted(
      it_recorded = mo_store->latest_per_material( iv_werks )
      iv_werks    = iv_werks
      iv_dispo    = iv_dispo
      iv_kunnr    = iv_kunnr ).

    APPEND |Plant { iv_werks }, where the shortfall goes| TO rt_line.

    IF ls_total-answered = 0.
      APPEND `Nothing has been allocated here yet` TO rt_line.
      RETURN.
    ENDIF.

    IF ls_total-short = 0.
      APPEND |{ ls_total-answered } line(s) answered in | &&
             |{ ls_total-materials } material(s), none of them short| TO rt_line.
      RETURN.
    ENDIF.

    " the goods first, because that is the block a plant can do least about
    " tonight and most about next month
    APPEND LINES OF block_lines(
      is_total   = ls_total
      iv_side    = c_side-supply
      iv_heading = `Stock that is not there` ) TO rt_line.

    APPEND LINES OF block_lines(
      is_total   = ls_total
      iv_side    = c_side-rules
      iv_heading = `Rules this plant chose` ) TO rt_line.

    " a strategy somebody wrote for their own system answers with a reason of
    " its own, and a report that dropped it would under-report the plant
    APPEND LINES OF block_lines(
      is_total   = ls_total
      iv_side    = c_side-other
      iv_heading = `Reasons of somebody's own` ) TO rt_line.

    APPEND || TO rt_line.
    APPEND |{ ls_total-answered } line(s) answered in { ls_total-materials } material(s), | &&
           |{ ls_total-short } short ({ percent( iv_part  = ls_total-short
                                                 iv_whole = ls_total-answered ) }%)| TO rt_line.

    " lines rather than quantities on purpose: one plant's materials are in
    " pieces, kilos and litres at the same time, and a total that adds those
    " up is a number that looks like an answer and is not one. A quantity per
    " line, with the unit next to it, is what the worklist of feature 48 is
    " for.
    APPEND `Counted in demand lines, not quantities: one plant's materials ` &&
           `are not all in the same unit` TO rt_line.

  ENDMETHOD.

  METHOD counted.

    DATA lt_dispo    TYPE zcl_alloc_owned_by=>ty_dispo_tab.
    DATA lt_material TYPE ty_matnr_tab.
    DATA lt_touched  TYPE ty_matnr_tab.

    IF iv_dispo IS NOT INITIAL.
      APPEND iv_dispo TO lt_dispo.
    ENDIF.

    DATA(lt_owned) = zcl_alloc_owned_by=>materials(
      iv_werks = iv_werks
      it_dispo = lt_dispo ).

    LOOP AT it_recorded INTO DATA(ls_recorded).

      IF zcl_alloc_owned_by=>is_owned(
          iv_matnr = ls_recorded-matnr
          it_owned = lt_owned
          it_dispo = lt_dispo ) = abap_false.
        CONTINUE.
      ENDIF.

      " somebody asking about one customer is asking what to tell them, and a
      " transfer with no customer at all is not part of that conversation
      IF iv_kunnr IS NOT INITIAL
          AND ls_recorded-customer <> iv_kunnr.
        CONTINUE.
      ENDIF.

      rs_total-answered = rs_total-answered + 1.

      IF NOT line_exists( lt_material[ table_line = ls_recorded-matnr ] ).
        APPEND ls_recorded-matnr TO lt_material.
      ENDIF.

      IF ls_recorded-shortfall <= 0.
        CONTINUE.
      ENDIF.

      rs_total-short = rs_total-short + 1.

      DATA(lv_side) = side_of( ls_recorded-reason ).

      DATA(lv_index) = line_index( rs_total-count[ reason = ls_recorded-reason ] ).
      IF lv_index = 0.
        APPEND VALUE #( side   = lv_side
                        reason = ls_recorded-reason ) TO rs_total-count.
        lv_index = lines( rs_total-count ).
      ENDIF.

      rs_total-count[ lv_index ]-lines = rs_total-count[ lv_index ]-lines + 1.

      " a reason that touched one material is a material to look at, and one
      " that touched forty is a rule to look at. Counting the material once
      " per reason is what tells those apart.
      IF NOT line_exists( lt_touched[ table_line = |{ ls_recorded-reason }{ ls_recorded-matnr }| ] ).
        APPEND |{ ls_recorded-reason }{ ls_recorded-matnr }| TO lt_touched.
        rs_total-count[ lv_index ]-materials = rs_total-count[ lv_index ]-materials + 1.
      ENDIF.

    ENDLOOP.

    rs_total-materials = lines( lt_material ).

    " biggest first: a block in reason order would put the rule that cost one
    " line above the one that cost two hundred
    SORT rs_total-count BY lines DESCENDING reason ASCENDING.

  ENDMETHOD.

  METHOD side_of.

    CASE iv_reason.
      WHEN zif_allocation=>c_reason-no_stock
          OR zif_allocation=>c_reason-supply_late.
        rv_side = c_side-supply.
      WHEN zif_allocation=>c_reason-customer_cap
          OR zif_allocation=>c_reason-quota
          OR zif_allocation=>c_reason-whole_units
          OR zif_allocation=>c_reason-complete_only
          OR zif_allocation=>c_reason-ship_together
          OR zif_allocation=>c_reason-too_little.
        rv_side = c_side-rules.
      WHEN OTHERS.
        rv_side = c_side-other.
    ENDCASE.

  ENDMETHOD.

  METHOD block_lines.

    DATA lv_shown TYPE i.

    LOOP AT is_total-count INTO DATA(ls_count) WHERE side = iv_side.

      " a heading with nothing under it is a heading nobody reads, which is the
      " rule features 81 and 150 settled for the explanation
      IF lv_shown = 0.
        APPEND || TO rt_line.
        APPEND iv_heading TO rt_line.
        APPEND format_row(
          iv_why       = `Reason`
          iv_lines     = `Lines`
          iv_share     = `Share`
          iv_materials = `Materials` ) TO rt_line.
      ENDIF.
      lv_shown = lv_shown + 1.

      APPEND format_row(
        iv_why       = zcl_alloc_reason_text=>text( ls_count-reason )
        iv_lines     = |{ ls_count-lines }|
        iv_share     = |{ percent( iv_part  = ls_count-lines
                                   iv_whole = is_total-short ) }%|
        iv_materials = |{ ls_count-materials }| ) TO rt_line.

    ENDLOOP.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |  { iv_why WIDTH = c_width_why }|
      && |{ iv_lines WIDTH = c_width_count ALIGN = RIGHT }|
      && |{ iv_share WIDTH = c_width_share ALIGN = RIGHT }|
      && |{ iv_materials WIDTH = c_width_count ALIGN = RIGHT }|.

  ENDMETHOD.

  METHOD percent.

    IF iv_whole = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_part * 100 / iv_whole.

  ENDMETHOD.

ENDCLASS.
