// Printable counterpart of templates/components/python_state.html.
// Accepts the same frames/objects data from yaml(), json(), or a dictionary.
// Browser composition v1 is accepted unchanged (compact/verbose, object/JSON string).
#let entries(value) = {
  if type(value) == dictionary { value.pairs() }
  else {
    assert(type(value) == array, message: "Expected a dictionary or an array of entries")
    value.map(item => (item.id, item))
  }
}

#let literal(value, kind) = {
  if kind == "NoneType" or value == none { "None" }
  else if kind == "bool" { if value { "True" } else { "False" } }
  else if kind == "str" { json.encode(value) }
  else if kind == "list" { "[]" }
  else if kind == "dict" { "{}" }
  else if type(value) == str { value }
  else { repr(value) }
}

#let composition-points(value) = {
  if value == none { return (:) }
  let payload = if type(value) == str { json(bytes(value)) } else { value }
  payload = payload.at("composition", default: payload)
  let version = payload.at("schema_version", default: payload.at("v", default: 1))
  assert(version == 1, message: "Unsupported composition schema version")
  let points = (:)
  let point(position) = {
    let xy = if type(position) == array { position } else {
      let nested = position.at("position", default: position)
      (nested.at("x", default: nested.at("left", default: none)),
       nested.at("y", default: nested.at("top", default: none)))
    }
    assert(xy.len() == 2, message: "Expected [x, y] in composition")
    for coordinate in xy {
      assert(type(coordinate) == int or type(coordinate) == float, message: "Composition coordinates must be numbers")
      assert(coordinate > -1000000000 and coordinate < 1000000000, message: "Composition coordinates must be finite")
    }
    xy
  }
  if "placements" in payload {
    for item in payload.placements {
      assert(not (item.key in points), message: "Duplicate composition key: " + item.key)
      points.insert(item.key, point(item))
    }
  } else {
    for (key, position) in payload.p { points.insert(key, point(position)) }
  }
  points
}

#let python-state(state, title: none, columns: 2, positions: (:), node-width: auto,
  composition: auto, font: auto, mono-font: "JetBrains Mono", edge-color: rgb("#0969da"), boxed: false) = context {
  assert(type(state) == dictionary, message: "State must be a dictionary")
  assert(columns > 0 and type(columns) == int, message: "columns must be a positive integer")
  let objects = entries(state.objects)
  let frames = entries(state.at("frames", default: (:)))
  let ids = objects.map(entry => entry.at(0))
  assert(ids.dedup().len() == ids.len(), message: "Duplicate object IDs")
  let frame-ids = frames.map(entry => entry.at(0))
  assert(frame-ids.dedup().len() == frame-ids.len(), message: "Duplicate frame IDs")
  let ink = rgb("#24292e")
  let blue = edge-color
  let row-height = 15pt
  let padding = 8pt
  let gap = 35pt
  let cell-size = 20pt
  let pair-gap = 4pt
  let separator-width = 9pt
  let nodes = ()
  let reference(target, label) = {
    assert(ids.contains(target), message: "Unknown object: " + target)
    (target: target, label: str(label))
  }
  for (id, frame) in frames {
    let names = frame.bindings.map(binding => binding.name)
    assert(names.dedup().len() == names.len(), message: "Duplicate binding in frame " + id)
    let refs = frame.bindings.map(binding => reference(binding.object, binding.name))
    nodes.push((key: "frame:" + id, kind: "frame", heading: frame.at("name", default: id), refs: refs, body: []))
  }
  for (id, object) in objects {
    let kind = object.at("type", default: object.at("kind", default: none))
    assert(("int", "float", "bool", "NoneType", "str", "list", "dict", "function", "object").contains(kind),
      message: "Unsupported type for " + id)
    let value = object.value
    let valid = if kind == "int" { type(value) == int }
      else if kind == "float" { type(value) == float or type(value) == int }
      else if kind == "bool" { type(value) == bool }
      else if kind == "NoneType" { value == none }
      else if kind == "str" or kind == "function" { type(value) == str }
      else if kind == "list" or kind == "dict" { type(value) == array }
      else { true }
    assert(valid, message: "Invalid value for " + id + " (" + kind + ")")
    let refs = ()
    if kind == "list" {
      for (index, item) in value.enumerate() { refs.push(reference(item.object, index)) }
    } else if kind == "dict" {
      for (index, pair) in value.enumerate() {
        refs.push(reference(pair.key.object, str(index) + ".key"))
        refs.push(reference(pair.value.object, str(index) + ".value"))
      }
    }
    let body = if refs.len() == 0 { raw(literal(value, kind)) } else { [] }
    let details = object.at("details", default: none)
    if details != none {
      let lines = if type(details) == array { details }
        else if type(details) == dictionary { details.pairs().map(p => str(p.at(0)) + ": " + str(p.at(1))) }
        else { (str(details),) }
      for detail in lines { body += [#linebreak()#raw(detail)] }
    }
    nodes.push((key: "object:" + id, kind: kind, heading: "type: " + kind, refs: refs, body: body))
  }
  let name-font = if font == auto { text.font } else { font }
  set text(font: "Noto Sans", size: 10pt, fill: ink)
  show raw: set text(font: mono-font, size: 8.5pt)
  set par(leading: 3pt)
  set block(spacing: 0pt)
  let placements = (:)
  let column-count = columns + if frames.len() > 0 { 1 } else { 0 }
  let bottoms = range(column-count).map(_ => 0pt)
  let column-widths = range(column-count).map(_ => 0pt)
  let node-sizes = (:)
  for (index, node) in nodes.enumerate() {
    let col = if index < frames.len() { 0 }
      else { calc.rem(index - frames.len(), columns) + if frames.len() > 0 { 1 } else { 0 } }
    let heading-width = measure(text(font: if node.kind == "frame" { name-font } else { "Noto Sans" },
      weight: if node.kind == "frame" { "bold" } else { "regular" }, node.heading)).width
    let content-width = if node.kind == "frame" {
      if node.refs.len() == 0 { 0pt } else {
        calc.max(..node.refs.map(ref => measure(text(font: name-font, size: 8.5pt, ref.label)).width + 12pt))
      }
    } else if node.kind == "list" and node.refs.len() > 0 { node.refs.len() * cell-size }
      else if node.kind == "dict" and node.refs.len() > 0 { 2 * cell-size + separator-width }
      else if node.body == [] { 0pt }
      else { measure(node.body).width }
    let natural-width = calc.max(54pt, heading-width + 2 * padding, content-width + 2 * padding)
    let box-width = if node-width == auto { natural-width } else { node-width }
    let body-height = if node.body == [] { 0pt } else { measure(block(width: box-width - 2 * padding, node.body)).height + 1pt }
    let refs-height = if node.kind == "list" and node.refs.len() > 0 { cell-size }
      else if node.kind == "dict" and node.refs.len() > 0 {
        let pairs = node.refs.len() / 2
        pairs * cell-size + (pairs - 1) * pair-gap
      }
      else { 0pt }
    let bottom-padding = if node.kind == "frame" { 6pt }
      else if node.kind != "list" and node.kind != "dict" { 6pt }
      else { padding }
    let height = if node.kind == "frame" and node.refs.len() > 0 {
      let last-label = node.refs.at(node.refs.len() - 1).label
      let label-height = measure(text(font: name-font, size: 8.5pt, last-label)).height
      padding + row-height * (node.refs.len() + 0.5) + calc.max(3pt, label-height / 2) + bottom-padding
    } else { padding + row-height + refs-height + body-height + bottom-padding }
    node-sizes.insert(node.key, (width: box-width, height: height))
    column-widths.at(col) = calc.max(column-widths.at(col), box-width)
  }
  for (index, node) in nodes.enumerate() {
    let col = if index < frames.len() { 0 }
      else { calc.rem(index - frames.len(), columns) + if frames.len() > 0 { 1 } else { 0 } }
    let x = 12pt
    for previous in range(col) { x += column-widths.at(previous) + gap }
    let size = node-sizes.at(node.key)
    let point = positions.at(node.key, default: (x, bottoms.at(col)))
    assert(point.at(0) >= 0pt and point.at(1) >= 0pt, message: "Positions must be non-negative lengths")
    placements.insert(node.key, (x: point.at(0), y: point.at(1), width: size.width, height: size.height))
    bottoms.at(col) = calc.max(bottoms.at(col), point.at(1) + size.height + 24pt)
  }
  let imported = composition-points(if composition == auto { state.at("composition", default: none) } else { composition })
  if imported.len() > 0 {
    assert(positions.len() == 0, message: "Use either browser composition or explicit print positions")
    assert(imported.keys().sorted() == placements.keys().sorted(),
      message: "Composition must contain exactly the current frame/object IDs; export it again after adding or removing nodes")
    let min-x = calc.min(..imported.values().map(p => p.at(0)))
    let min-y = calc.min(..imported.values().map(p => p.at(1)))
    // Preserve relative positions. Expand coordinates uniformly if the print font
    // makes boxes overlap; the whole drawing is then fitted to the text width.
    let unit = 0.75pt
    let keys = imported.keys()
    for i in range(keys.len()) {
      for j in range(i + 1, keys.len()) {
        let a = imported.at(keys.at(i))
        let b = imported.at(keys.at(j))
        let dx = calc.abs(a.at(0) - b.at(0))
        let dy = calc.abs(a.at(1) - b.at(1))
        assert(dx > 0 or dy > 0, message: "Composition has coincident nodes")
        let top-key = if a.at(1) <= b.at(1) { keys.at(i) } else { keys.at(j) }
        let left-key = if a.at(0) <= b.at(0) { keys.at(i) } else { keys.at(j) }
        let horizontal = if dx > 0 { (placements.at(left-key).width + 12pt) / dx } else { 1000000pt }
        let vertical = if dy > 0 { (placements.at(top-key).height + 12pt) / dy } else { 1000000pt }
        unit = calc.max(unit, calc.min(horizontal, vertical))
      }
    }
    for (key, p) in imported {
      let item = placements.at(key)
      item.x = 12pt + (p.at(0) - min-x) * unit
      item.y = (p.at(1) - min-y) * unit
      placements.insert(key, item)
    }
  }
  let width = 1pt
  let height = 1pt
  for (_, point) in placements { width = calc.max(width, point.x + point.width); height = calc.max(height, point.y + point.height) }
  let normal(side) = if side == "left" { (-1, 0) }
    else if side == "right" { (1, 0) }
    else if side == "top" { (0, -1) }
    else { (0, 1) }
  let port(node, index, point) = {
    if node.kind == "list" {
      (point.x + padding + cell-size * (index + 0.5), point.y + padding + row-height + cell-size / 2)
    } else if node.kind == "dict" {
      let col = calc.rem(index, 2)
      (point.x + padding + cell-size / 2 + col * (cell-size + separator-width),
       point.y + padding + row-height + calc.floor(index / 2) * (cell-size + pair-gap) + cell-size / 2)
    } else {
      let dest = placements.at("object:" + node.refs.at(index).target)
      let on-left = dest.x + dest.width / 2 < point.x + point.width / 2
      (if on-left { point.x + padding + 2.5pt } else { point.x + point.width - padding - 2.5pt },
       point.y + padding + row-height * (index + 1.5))
    }
  }
  let source-side(node, from, source, dest) = {
    if node.kind == "frame" {
      if dest.x + dest.width / 2 < from.x + from.width / 2 { "left" } else { "right" }
    } else if dest.x > source.at(0) { "right" }
      else if dest.x + dest.width < source.at(0) { "left" }
      else if dest.y > source.at(1) { "bottom" }
      else { "top" }
  }
  let target-side(source, dest) = {
    if source.at(0) < dest.x { "left" }
    else if source.at(0) > dest.x + dest.width { "right" }
    else if source.at(1) < dest.y { "top" }
    else { "bottom" }
  }
  let drawing = block(width: width + 12pt, height: height + 16pt, {
    // Match the browser's cubic connectors, accent color, and solid arrowheads.
    let edges = {
      for node in nodes {
        let from = placements.at(node.key)
        for (index, ref) in node.refs.enumerate() {
        let dest = placements.at("object:" + ref.target)
        let source = port(node, index, from)
        let start-side = source-side(node, from, source, dest)
        let end-side = target-side(source, dest)
        let sn = normal(start-side)
        let en = normal(end-side)
        let target = if end-side == "left" { (dest.x - 5pt, calc.max(dest.y + 2pt, calc.min(source.at(1), dest.y + dest.height - 2pt))) }
          else if end-side == "right" { (dest.x + dest.width + 5pt, calc.max(dest.y + 2pt, calc.min(source.at(1), dest.y + dest.height - 2pt))) }
          else { (calc.max(dest.x + 2pt, calc.min(source.at(0), dest.x + dest.width - 2pt)),
            if end-side == "top" { dest.y - 5pt } else { dest.y + dest.height + 5pt }) }
        let start = (source.at(0) + sn.at(0) * 8pt, source.at(1) + sn.at(1) * 8pt)
        let line-end = (target.at(0) + en.at(0) * 6pt, target.at(1) + en.at(1) * 6pt)
        let distance = calc.max(calc.abs(line-end.at(0) - start.at(0)), calc.abs(line-end.at(1) - start.at(1)))
        let bend = calc.min(65pt, calc.max(20pt, distance * 0.32))
        let control1 = (start.at(0) + sn.at(0) * bend, start.at(1) + sn.at(1) * bend)
        let control2 = (line-end.at(0) + en.at(0) * bend, line-end.at(1) + en.at(1) * bend)
        place(top + left, curve(
          curve.move(start), curve.cubic(control1, control2, line-end),
          stroke: (paint: blue, thickness: 1.5pt, cap: "round"),
        ))
        let base = (target.at(0) + en.at(0) * 7pt, target.at(1) + en.at(1) * 7pt)
        let tangent = (-en.at(1), en.at(0))
        place(top + left, polygon(target,
          (base.at(0) + tangent.at(0) * 3.5pt, base.at(1) + tangent.at(1) * 3.5pt),
          (base.at(0) - tangent.at(0) * 3.5pt, base.at(1) - tangent.at(1) * 3.5pt),
          fill: blue, stroke: none))
        }
      }
    }
    for node in nodes {
      let point = placements.at(node.key)
      place(top + left, dx: point.x, dy: point.y,
        block(width: point.width, height: point.height, stroke: 0.6pt + ink, radius: 1pt, fill: white, inset: padding, {
          block(height: row-height,
            text(font: if node.kind == "frame" { name-font } else { "Noto Sans" },
              weight: if node.kind == "frame" { "bold" } else { "regular" }, node.heading))
          node.body
        }))
      for (index, ref) in node.refs.enumerate() {
        let source = port(node, index, point)
        if node.kind == "frame" {
          let label-x = if source.at(0) < point.x + point.width / 2 { point.x + padding + 9pt } else { point.x + padding }
          let label = text(font: name-font, size: 8.5pt, ref.label)
          place(top + left, dx: label-x, dy: source.at(1) - measure(label).height / 2, label)
        } else {
          let cell-x = if node.kind == "list" { point.x + padding + index * cell-size }
            else { point.x + padding + calc.rem(index, 2) * (cell-size + separator-width) }
          let cell-y = if node.kind == "list" { point.y + padding + row-height }
            else { point.y + padding + row-height + calc.floor(index / 2) * (cell-size + pair-gap) }
          place(top + left, dx: cell-x, dy: cell-y,
            block(width: cell-size, height: cell-size, stroke: 0.6pt + ink, fill: white))
          if node.kind == "dict" and calc.rem(index, 2) == 0 {
            place(top + left, dx: cell-x + cell-size + 3pt, dy: cell-y + 2pt, raw(":"))
          }
        }
        place(top + left, dx: source.at(0) - 3pt, dy: source.at(1) - 3pt,
          circle(radius: 3pt, fill: blue))
      }
    }
    edges
  })
  block(width: 100%, above: 12pt, below: 12pt, stroke: if boxed { 0.6pt + ink } else { none }, radius: 2pt, inset: 10pt, breakable: false, {
    if title != none { text(weight: "bold", title); v(8pt) }
    layout(size => {
      if width + 12pt > size.width { scale(x: size.width / (width + 12pt) * 100%, y: size.width / (width + 12pt) * 100%, reflow: true, drawing) }
      else { drawing }
    })
  })
}
