import 'package:flutter/material.dart';
import 'board_element.dart';
import 'connection_binding.dart';
import 'shape_type.dart';
import 'stroke_fill_style.dart';

enum DiagramTemplateType {
  flowchart('Flowchart', 'Process logic, decision diamonds, and connectors', Icons.account_tree_outlined),
  mindMap('Mind Map', 'Central concept with branching subtopics', Icons.hub_outlined),
  kanban('Kanban Board', 'To-Do, In-Progress, and Done columns with sticky notes', Icons.view_column_outlined),
  architecture('System Architecture', 'Client, Gateway, Services, and Database components', Icons.cloud_done_outlined);

  const DiagramTemplateType(this.title, this.description, this.icon);
  final String title;
  final String description;
  final IconData icon;
}

class TemplateGenerator {
  static List<BoardElement> generate(DiagramTemplateType type, Offset center) {
    final now = DateTime.now().millisecondsSinceEpoch;
    switch (type) {
      case DiagramTemplateType.flowchart:
        return _generateFlowchart(center, now);
      case DiagramTemplateType.mindMap:
        return _generateMindMap(center, now);
      case DiagramTemplateType.kanban:
        return _generateKanban(center, now);
      case DiagramTemplateType.architecture:
        return _generateArchitecture(center, now);
    }
  }

  static List<BoardElement> _generateFlowchart(Offset c, int now) {
    // 1. Start Node (Rounded Box)
    final start = BoardElement(
      id: 'flow_start_$now',
      type: ShapeType.roundedRectangle,
      start: c + const Offset(-70, -180),
      end: c + const Offset(70, -130),
      color: const Color(0xFF2F9E44),
      fillColor: const Color(0xFFD3F9D8),
      fillStyle: FillStyle.semi,
      text: 'Start',
      fontSize: 18.0,
      strokeWidth: 2.5,
    );

    // 2. Decision Diamond
    final decision = BoardElement(
      id: 'flow_dec_$now',
      type: ShapeType.diamond,
      start: c + const Offset(-90, -80),
      end: c + const Offset(90, 30),
      color: const Color(0xFFE8590C),
      fillColor: const Color(0xFFFFE8CC),
      fillStyle: FillStyle.semi,
      text: 'Is Valid?',
      fontSize: 16.0,
      strokeWidth: 2.5,
    );

    // 3. Process Node (Left - No)
    final procNo = BoardElement(
      id: 'flow_no_$now',
      type: ShapeType.rectangle,
      start: c + const Offset(-250, 70),
      end: c + const Offset(-110, 130),
      color: const Color(0xFFE03131),
      fillColor: const Color(0xFFFFDEEB),
      fillStyle: FillStyle.semi,
      text: 'Show Error',
      fontSize: 16.0,
      strokeWidth: 2.5,
    );

    // 4. Process Node (Right - Yes)
    final procYes = BoardElement(
      id: 'flow_yes_$now',
      type: ShapeType.rectangle,
      start: c + const Offset(110, 70),
      end: c + const Offset(250, 130),
      color: const Color(0xFF1971C2),
      fillColor: const Color(0xFFD0EBFF),
      fillStyle: FillStyle.semi,
      text: 'Process Data',
      fontSize: 16.0,
      strokeWidth: 2.5,
    );

    // 5. End Node
    final end = BoardElement(
      id: 'flow_end_$now',
      type: ShapeType.roundedRectangle,
      start: c + const Offset(-70, 180),
      end: c + const Offset(70, 230),
      color: const Color(0xFF7048E8),
      fillColor: const Color(0xFFE5DBFF),
      fillStyle: FillStyle.semi,
      text: 'End',
      fontSize: 18.0,
      strokeWidth: 2.5,
    );

    // Connectors
    final arr1 = BoardElement(
      id: 'flow_arr1_$now',
      type: ShapeType.arrow,
      start: ConnectionBinding.getAnchorPosition(start, AnchorPoint.bottom),
      end: ConnectionBinding.getAnchorPosition(decision, AnchorPoint.top),
      color: const Color(0xFF1F2430),
      startBinding: ConnectionBinding(elementId: start.id, anchor: AnchorPoint.bottom),
      endBinding: ConnectionBinding(elementId: decision.id, anchor: AnchorPoint.top),
    );

    final arr2 = BoardElement(
      id: 'flow_arr2_$now',
      type: ShapeType.arrow,
      start: ConnectionBinding.getAnchorPosition(decision, AnchorPoint.left),
      end: ConnectionBinding.getAnchorPosition(procNo, AnchorPoint.top),
      color: const Color(0xFF1F2430),
      startBinding: ConnectionBinding(elementId: decision.id, anchor: AnchorPoint.left),
      endBinding: ConnectionBinding(elementId: procNo.id, anchor: AnchorPoint.top),
    );

    final arr3 = BoardElement(
      id: 'flow_arr3_$now',
      type: ShapeType.arrow,
      start: ConnectionBinding.getAnchorPosition(decision, AnchorPoint.right),
      end: ConnectionBinding.getAnchorPosition(procYes, AnchorPoint.top),
      color: const Color(0xFF1F2430),
      startBinding: ConnectionBinding(elementId: decision.id, anchor: AnchorPoint.right),
      endBinding: ConnectionBinding(elementId: procYes.id, anchor: AnchorPoint.top),
    );

    final arr4 = BoardElement(
      id: 'flow_arr4_$now',
      type: ShapeType.arrow,
      start: ConnectionBinding.getAnchorPosition(procYes, AnchorPoint.bottom),
      end: ConnectionBinding.getAnchorPosition(end, AnchorPoint.right),
      color: const Color(0xFF1F2430),
      startBinding: ConnectionBinding(elementId: procYes.id, anchor: AnchorPoint.bottom),
      endBinding: ConnectionBinding(elementId: end.id, anchor: AnchorPoint.right),
    );

    return [start, decision, procNo, procYes, end, arr1, arr2, arr3, arr4];
  }

  static List<BoardElement> _generateMindMap(Offset c, int now) {
    // Central concept
    final centerNode = BoardElement(
      id: 'mm_center_$now',
      type: ShapeType.ellipse,
      start: c + const Offset(-80, -45),
      end: c + const Offset(80, 45),
      color: const Color(0xFF3B5BDB),
      fillColor: const Color(0xFFD0EBFF),
      fillStyle: FillStyle.solid,
      text: 'Main Idea',
      fontSize: 20.0,
      strokeWidth: 3.0,
    );

    final branches = [
      (const Offset(-220, -130), const Color(0xFFE03131), 'Research'),
      (const Offset(220, -130), const Color(0xFF2F9E44), 'Design'),
      (const Offset(-220, 130), const Color(0xFFE8590C), 'Execution'),
      (const Offset(220, 130), const Color(0xFF7048E8), 'Launch'),
    ];

    final elements = <BoardElement>[centerNode];
    var i = 0;
    for (final (offset, color, label) in branches) {
      final child = BoardElement(
        id: 'mm_child_${now}_$i',
        type: ShapeType.roundedRectangle,
        start: c + offset + const Offset(-60, -25),
        end: c + offset + const Offset(60, 25),
        color: color,
        fillColor: color.withValues(alpha: 0.15),
        fillStyle: FillStyle.semi,
        text: label,
        fontSize: 16.0,
      );

      final line = BoardElement(
        id: 'mm_line_${now}_$i',
        type: ShapeType.line,
        start: centerNode.bounds.center,
        end: child.bounds.center,
        color: color,
        strokeWidth: 2.0,
        strokeStyle: StrokeStyle.dashed,
      );

      elements.add(line);
      elements.add(child);
      i++;
    }
    return elements;
  }

  static List<BoardElement> _generateKanban(Offset c, int now) {
    const colWidth = 200.0;
    const colHeight = 360.0;
    const gap = 20.0;

    final cols = [
      ('To Do', const Color(0xFFFFDEEB), const Offset(-colWidth - gap, 0)),
      ('In Progress', const Color(0xFFFFF3BF), const Offset(0, 0)),
      ('Done', const Color(0xFFD3F9D8), const Offset(colWidth + gap, 0)),
    ];

    final elements = <BoardElement>[];
    var i = 0;
    for (final (title, noteColor, pos) in cols) {
      final colTopLeft = c + pos + const Offset(-colWidth / 2, -colHeight / 2);
      final colCard = BoardElement(
        id: 'kb_col_${now}_$i',
        type: ShapeType.roundedRectangle,
        start: colTopLeft,
        end: colTopLeft + const Offset(colWidth, colHeight),
        color: const Color(0xFF868E96),
        fillColor: const Color(0xFFF1F3F5),
        fillStyle: FillStyle.semi,
        strokeWidth: 1.5,
      );

      final colHeader = BoardElement(
        id: 'kb_hdr_${now}_$i',
        type: ShapeType.text,
        start: colTopLeft + const Offset(16, 12),
        end: colTopLeft + const Offset(colWidth - 16, 40),
        color: const Color(0xFF212529),
        text: title,
        fontSize: 18.0,
      );

      final sticky1 = BoardElement(
        id: 'kb_st1_${now}_$i',
        type: ShapeType.stickyNote,
        start: colTopLeft + const Offset(14, 55),
        end: colTopLeft + const Offset(colWidth - 14, 155),
        color: const Color(0xFF212529),
        fillColor: noteColor,
        text: 'Task #$i item A',
        fontSize: 15.0,
      );

      final sticky2 = BoardElement(
        id: 'kb_st2_${now}_$i',
        type: ShapeType.stickyNote,
        start: colTopLeft + const Offset(14, 170),
        end: colTopLeft + const Offset(colWidth - 14, 270),
        color: const Color(0xFF212529),
        fillColor: noteColor,
        text: 'Task #$i item B',
        fontSize: 15.0,
      );

      elements.addAll([colCard, colHeader, sticky1, sticky2]);
      i++;
    }
    return elements;
  }

  static List<BoardElement> _generateArchitecture(Offset c, int now) {
    // Client -> Gateway -> Services -> Database
    final client = BoardElement(
      id: 'arch_client_$now',
      type: ShapeType.roundedRectangle,
      start: c + const Offset(-320, -35),
      end: c + const Offset(-200, 35),
      color: const Color(0xFF1098AD),
      fillColor: const Color(0xFFD0EBFF),
      fillStyle: FillStyle.semi,
      text: 'Web / Mobile\nClient',
      fontSize: 15.0,
    );

    final gateway = BoardElement(
      id: 'arch_gw_$now',
      type: ShapeType.rectangle,
      start: c + const Offset(-130, -55),
      end: c + const Offset(-30, 55),
      color: const Color(0xFF7048E8),
      fillColor: const Color(0xFFE5DBFF),
      fillStyle: FillStyle.semi,
      text: 'API\nGateway',
      fontSize: 15.0,
    );

    final service = BoardElement(
      id: 'arch_svc_$now',
      type: ShapeType.rectangle,
      start: c + const Offset(50, -55),
      end: c + const Offset(160, 55),
      color: const Color(0xFFE8590C),
      fillColor: const Color(0xFFFFE8CC),
      fillStyle: FillStyle.semi,
      text: 'Backend\nServices',
      fontSize: 15.0,
    );

    final db = BoardElement(
      id: 'arch_db_$now',
      type: ShapeType.ellipse,
      start: c + const Offset(230, -45),
      end: c + const Offset(330, 45),
      color: const Color(0xFF2F9E44),
      fillColor: const Color(0xFFD3F9D8),
      fillStyle: FillStyle.semi,
      text: 'PostgreSQL\nDatabase',
      fontSize: 14.0,
    );

    final arr1 = BoardElement(
      id: 'arch_a1_$now',
      type: ShapeType.arrow,
      start: client.bounds.centerRight,
      end: gateway.bounds.centerLeft,
      color: const Color(0xFF1F2430),
      strokeWidth: 2.0,
    );

    final arr2 = BoardElement(
      id: 'arch_a2_$now',
      type: ShapeType.arrow,
      start: gateway.bounds.centerRight,
      end: service.bounds.centerLeft,
      color: const Color(0xFF1F2430),
      strokeWidth: 2.0,
    );

    final arr3 = BoardElement(
      id: 'arch_a3_$now',
      type: ShapeType.arrow,
      start: service.bounds.centerRight,
      end: db.bounds.centerLeft,
      color: const Color(0xFF1F2430),
      strokeWidth: 2.0,
    );

    return [client, gateway, service, db, arr1, arr2, arr3];
  }
}
