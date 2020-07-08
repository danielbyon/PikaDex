//
//  MachineList.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/20/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct MachineList: View {

    let title: String
    let game: Game
    
    @FetchRequest private var machines: FetchedResults<Machine>
    @State private var selectedMachineType: MachineType = .tm

    private var segmentedControlValues: [MachineType] {
        var values: [MachineType] = []
        if !tms.isEmpty {
            values.append(.tm)
        }
        if !hms.isEmpty {
            values.append(.hm)
        }
        if !trs.isEmpty {
            values.append(.tr)
        }
        return values
    }
    private var segmentedControl: some View {
        Group {
            if segmentedControlValues.count > 1 {
                SegmentedControl(
                    titles: segmentedControlValues.map { $0.title },
                    values: segmentedControlValues, selectedSegmentIndex: $selectedMachineType)
            } else {
                EmptyView()
            }
        }
    }
    private var tms: [Machine] { machines.filter { $0.type == .tm } }
    private var hms: [Machine] { machines.filter { $0.type == .hm } }
    private var trs: [Machine] { machines.filter { $0.type == .tr } }

    var body: some View {
        List {
            segmentedControl
            if selectedMachineType == .tm {
                AlternatingBackgroundForEach(tms) {
                    self.cell(for: $0)
                }
            } else if selectedMachineType == .hm {
                AlternatingBackgroundForEach(hms) {
                    self.cell(for: $0)
                }
            } else if selectedMachineType == .tr {
                AlternatingBackgroundForEach(trs) {
                    self.cell(for: $0)
                }
            }
        }
        .navigationBarTitle(title)
    }

    init(title: String, game: Game) {
        self.title = title
        self.game = game
        _machines = FetchRequest(fetchRequest: Machine.allFetchRequest(for: game))

    }

    private func cell(for machine: Machine) -> some View {
        NavigationLink(destination: MoveDetail(move: machine.move, game: game).injectDependencies()) {
            MachineCell(machine: machine, game: game)
        }
    }

}

struct MachineList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MachineList(title: "TMs / TRs", game: .sword)
                .injectDependencies()
        }
    }
}

private struct MachineCell: View {

    let machine: Machine
    let game: Game

    var body: some View {
        HStack {
            MoveCell(move: machine.move, game: game)
            Text("\(machine.type.title) \(NumberFormatter.twoDigit.string(from: NSNumber(value: machine.number)) ?? "")")
        }
        .contentShape(Rectangle())
        .monospacedBody()
    }

}
