import React from 'react';

export default function TableLoader({ rows = 5, columns = 5 }) {
  return (
    <tbody className="divide-y divide-slate-100">
      {Array.from({ length: rows }).map((_, rowIndex) => (
        <tr key={rowIndex} className="animate-pulse">
          {Array.from({ length: columns }).map((_, colIndex) => (
            <td key={colIndex} className="p-4">
              <div className="h-4 bg-slate-200 rounded w-3/4"></div>
            </td>
          ))}
        </tr>
      ))}
    </tbody>
  );
}
