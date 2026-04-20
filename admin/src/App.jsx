import React, { useState, useEffect, useCallback } from 'react'

const API_BASE = '/gas/api/admin'

const COLUMNS = [
  { key: 'HP_IMEI', label: 'IMEI', width: 220 },
  { key: 'HP_State', label: '상태', width: 60 },
  { key: 'HP_Model', label: '모델', width: 140 },
  { key: 'HP_SNO', label: '전화번호', width: 120 },
  { key: 'APP_VER', label: '앱버전', width: 90 },
  { key: 'SVR_IP', label: '서버IP', width: 160 },
  { key: 'SVR_DBName', label: 'DB명', width: 100 },
  { key: 'SVR_Port', label: '포트', width: 60 },
  { key: 'Login_Co', label: '업체코드', width: 100 },
  { key: 'Login_Name', label: '이름', width: 100 },
  { key: 'Login_User', label: '아이디', width: 100 },
  { key: 'Login_Pass', label: '비밀번호', width: 100 },
  { key: 'BA_Area_CODE', label: '지역코드', width: 100 },
  { key: 'BA_SW_CODE', label: 'SW코드', width: 80 },
  { key: 'BA_Gubun_CODE', label: '구분코드', width: 80 },
  { key: 'BA_JY_Code', label: 'JY코드', width: 80 },
  { key: 'BA_OrderBy', label: '정렬', width: 60 },
  { key: 'Safe_SW_CODE', label: 'Safe코드', width: 80 },
  { key: 'License_Date', label: '라이센스', width: 110 },
  { key: 'Login_StartDate', label: '시작일', width: 110 },
  { key: 'Login_LastDate', label: '최종접속', width: 150 },
  { key: 'Login_EndDate', label: '종료일', width: 110 },
  { key: 'Login_info', label: '로그인정보', width: 100 },
  { key: 'Login_Memo', label: '메모', width: 120 },
  { key: 'APP_Cert', label: '권한', width: 60 },
  { key: 'GPS_SEARCH_YN', label: 'GPS', width: 50 },
]

const EMPTY_ROW = COLUMNS.reduce((acc, col) => ({ ...acc, [col.key]: '' }), {})

export default function App() {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [editRow, setEditRow] = useState(null)
  const [editData, setEditData] = useState({})
  const [insertMode, setInsertMode] = useState(false)
  const [newData, setNewData] = useState({ ...EMPTY_ROW })
  const [search, setSearch] = useState('')

  const fetchUsers = useCallback(async () => {
    setLoading(true)
    setError('')
    try {
      const res = await fetch(`${API_BASE}/users`)
      if (!res.ok) {
        const text = await res.text()
        setError(`서버 오류 (${res.status}): ${text || '응답 없음'}`)
        setLoading(false)
        return
      }
      const text = await res.text()
      if (!text) {
        setError('서버에서 빈 응답이 반환되었습니다')
        setLoading(false)
        return
      }
      const json = JSON.parse(text)
      if (json.resultCode === 0) {
        setUsers(json.resultData || [])
      } else {
        setError(json.result || '조회 실패')
      }
    } catch (e) {
      setError('서버 연결 실패: ' + e.message)
    }
    setLoading(false)
  }, [])

  useEffect(() => { fetchUsers() }, [fetchUsers])

  const handleEdit = (user) => {
    setEditRow(user.HP_IMEI)
    setEditData({ ...user })
    setInsertMode(false)
  }

  const handleEditChange = (key, value) => {
    setEditData(prev => ({ ...prev, [key]: value }))
  }

  const handleSave = async () => {
    try {
      const res = await fetch(`${API_BASE}/users/${encodeURIComponent(editRow)}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(editData),
      })
      const json = await res.json()
      if (json.resultCode === 0) {
        setEditRow(null)
        fetchUsers()
      } else {
        alert('수정 실패: ' + json.result)
      }
    } catch (e) {
      alert('수정 실패: ' + e.message)
    }
  }

  const handleDelete = async (hpImei) => {
    if (!confirm(`정말 삭제하시겠습니까?\nIMEI: ${hpImei}`)) return
    try {
      const res = await fetch(`${API_BASE}/users/${encodeURIComponent(hpImei)}`, {
        method: 'DELETE',
      })
      const json = await res.json()
      if (json.resultCode === 0) {
        fetchUsers()
      } else {
        alert('삭제 실패: ' + json.result)
      }
    } catch (e) {
      alert('삭제 실패: ' + e.message)
    }
  }

  const handleInsert = async () => {
    const filled = Object.entries(newData).filter(([, v]) => v.trim() !== '')
    if (filled.length === 0) {
      alert('최소 1개 이상의 필드를 입력하세요')
      return
    }
    if (!newData.HP_IMEI.trim()) {
      alert('HP_IMEI는 필수입니다')
      return
    }
    try {
      const res = await fetch(`${API_BASE}/users`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newData),
      })
      const json = await res.json()
      if (json.resultCode === 0) {
        setInsertMode(false)
        setNewData({ ...EMPTY_ROW })
        fetchUsers()
      } else {
        alert('등록 실패: ' + json.result)
      }
    } catch (e) {
      alert('등록 실패: ' + e.message)
    }
  }

  const filtered = users.filter(u => {
    if (!search) return true
    const s = search.toLowerCase()
    return COLUMNS.some(col => (u[col.key] || '').toString().toLowerCase().includes(s))
  })

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <h1 style={styles.title}>AppUser_Safe 관리</h1>
        <span style={styles.count}>총 {filtered.length}건</span>
      </header>

      <div style={styles.toolbar}>
        <input
          style={styles.searchInput}
          placeholder="검색 (IMEI, 이름, 전화번호 등)"
          value={search}
          onChange={e => setSearch(e.target.value)}
        />
        <button style={styles.btnPrimary} onClick={() => { setInsertMode(true); setEditRow(null) }}>
          + 신규 등록
        </button>
        <button style={styles.btnSecondary} onClick={fetchUsers}>
          새로고침
        </button>
      </div>

      {error && <div style={styles.error}>{error}</div>}

      {insertMode && (
        <div style={styles.insertPanel}>
          <h3 style={styles.insertTitle}>신규 사용자 등록</h3>
          <div style={styles.insertGrid}>
            {COLUMNS.map(col => (
              <div key={col.key} style={styles.insertField}>
                <label style={styles.insertLabel}>{col.label}</label>
                <input
                  style={styles.insertInput}
                  value={newData[col.key]}
                  onChange={e => setNewData(prev => ({ ...prev, [col.key]: e.target.value }))}
                  placeholder={col.key}
                />
              </div>
            ))}
          </div>
          <div style={styles.insertActions}>
            <button style={styles.btnSave} onClick={handleInsert}>등록</button>
            <button style={styles.btnCancel} onClick={() => { setInsertMode(false); setNewData({ ...EMPTY_ROW }) }}>취소</button>
          </div>
        </div>
      )}

      <div style={styles.tableWrap}>
        {loading ? (
          <div style={styles.loading}>로딩중...</div>
        ) : (
          <table style={styles.table}>
            <thead>
              <tr>
                <th style={{ ...styles.th, width: 100, position: 'sticky', left: 0, zIndex: 3, background: '#1e293b' }}>액션</th>
                {COLUMNS.map(col => (
                  <th key={col.key} style={{ ...styles.th, minWidth: col.width }}>{col.label}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((user, idx) => {
                const isEditing = editRow === user.HP_IMEI
                return (
                  <tr key={user.HP_IMEI || idx} style={idx % 2 === 0 ? styles.rowEven : styles.rowOdd}>
                    <td style={{ ...styles.td, position: 'sticky', left: 0, zIndex: 2, background: idx % 2 === 0 ? '#f8fafc' : '#fff' }}>
                      {isEditing ? (
                        <div style={styles.actionBtns}>
                          <button style={styles.btnSaveSmall} onClick={handleSave}>저장</button>
                          <button style={styles.btnCancelSmall} onClick={() => setEditRow(null)}>취소</button>
                        </div>
                      ) : (
                        <div style={styles.actionBtns}>
                          <button style={styles.btnEditSmall} onClick={() => handleEdit(user)}>수정</button>
                          <button style={styles.btnDeleteSmall} onClick={() => handleDelete(user.HP_IMEI)}>삭제</button>
                        </div>
                      )}
                    </td>
                    {COLUMNS.map(col => (
                      <td key={col.key} style={styles.td}>
                        {isEditing ? (
                          <input
                            style={styles.editInput}
                            value={editData[col.key] || ''}
                            onChange={e => handleEditChange(col.key, e.target.value)}
                            disabled={col.key === 'HP_IMEI'}
                          />
                        ) : (
                          <span style={styles.cellText}>{user[col.key] || ''}</span>
                        )}
                      </td>
                    ))}
                  </tr>
                )
              })}
              {filtered.length === 0 && (
                <tr>
                  <td colSpan={COLUMNS.length + 1} style={styles.empty}>데이터가 없습니다</td>
                </tr>
              )}
            </tbody>
          </table>
        )}
      </div>
    </div>
  )
}

const styles = {
  container: {
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    padding: '20px',
    width: '100%',
    boxSizing: 'border-box',
    background: '#f1f5f9',
    minHeight: '100vh',
  },
  header: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
    marginBottom: '16px',
  },
  title: {
    fontSize: '22px',
    fontWeight: 700,
    color: '#1e293b',
    margin: 0,
  },
  count: {
    fontSize: '14px',
    color: '#64748b',
    background: '#e2e8f0',
    padding: '4px 12px',
    borderRadius: '12px',
  },
  toolbar: {
    display: 'flex',
    gap: '10px',
    marginBottom: '16px',
    flexWrap: 'wrap',
  },
  searchInput: {
    flex: 1,
    minWidth: '200px',
    padding: '10px 14px',
    border: '1px solid #cbd5e1',
    borderRadius: '8px',
    fontSize: '14px',
    outline: 'none',
  },
  btnPrimary: {
    padding: '10px 20px',
    background: '#2563eb',
    color: '#fff',
    border: 'none',
    borderRadius: '8px',
    fontSize: '14px',
    fontWeight: 600,
    cursor: 'pointer',
  },
  btnSecondary: {
    padding: '10px 20px',
    background: '#475569',
    color: '#fff',
    border: 'none',
    borderRadius: '8px',
    fontSize: '14px',
    cursor: 'pointer',
  },
  error: {
    padding: '12px 16px',
    background: '#fef2f2',
    color: '#dc2626',
    borderRadius: '8px',
    marginBottom: '16px',
    fontSize: '14px',
  },
  insertPanel: {
    background: '#fff',
    border: '2px solid #2563eb',
    borderRadius: '12px',
    padding: '20px',
    marginBottom: '16px',
  },
  insertTitle: {
    fontSize: '16px',
    fontWeight: 600,
    color: '#1e293b',
    margin: '0 0 16px 0',
  },
  insertGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))',
    gap: '10px',
  },
  insertField: {
    display: 'flex',
    flexDirection: 'column',
    gap: '4px',
  },
  insertLabel: {
    fontSize: '12px',
    fontWeight: 600,
    color: '#475569',
  },
  insertInput: {
    padding: '8px 10px',
    border: '1px solid #cbd5e1',
    borderRadius: '6px',
    fontSize: '13px',
    outline: 'none',
  },
  insertActions: {
    display: 'flex',
    gap: '10px',
    marginTop: '16px',
  },
  btnSave: {
    padding: '10px 24px',
    background: '#16a34a',
    color: '#fff',
    border: 'none',
    borderRadius: '8px',
    fontSize: '14px',
    fontWeight: 600,
    cursor: 'pointer',
  },
  btnCancel: {
    padding: '10px 24px',
    background: '#94a3b8',
    color: '#fff',
    border: 'none',
    borderRadius: '8px',
    fontSize: '14px',
    cursor: 'pointer',
  },
  tableWrap: {
    display: 'block',
    overflowX: 'auto',
    overflowY: 'auto',
    width: '100%',
    background: '#fff',
    borderRadius: '12px',
    boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
    WebkitOverflowScrolling: 'touch',
  },
  table: {
    width: '2400px',
    borderCollapse: 'collapse',
    fontSize: '13px',
    tableLayout: 'fixed',
  },
  th: {
    padding: '12px 10px',
    textAlign: 'left',
    color: '#e2e8f0',
    fontWeight: 600,
    fontSize: '12px',
    whiteSpace: 'nowrap',
    borderBottom: '2px solid #334155',
    position: 'sticky',
    top: 0,
    zIndex: 2,
    background: '#1e293b',
  },
  td: {
    padding: '8px 10px',
    borderBottom: '1px solid #e2e8f0',
    whiteSpace: 'nowrap',
  },
  rowEven: {
    background: '#f8fafc',
  },
  rowOdd: {
    background: '#fff',
  },
  cellText: {
    fontSize: '13px',
    color: '#334155',
  },
  editInput: {
    padding: '4px 6px',
    border: '1px solid #93c5fd',
    borderRadius: '4px',
    fontSize: '13px',
    width: '100%',
    boxSizing: 'border-box',
    outline: 'none',
    background: '#eff6ff',
  },
  actionBtns: {
    display: 'flex',
    gap: '4px',
  },
  btnEditSmall: {
    padding: '4px 10px',
    background: '#2563eb',
    color: '#fff',
    border: 'none',
    borderRadius: '4px',
    fontSize: '12px',
    cursor: 'pointer',
  },
  btnDeleteSmall: {
    padding: '4px 10px',
    background: '#dc2626',
    color: '#fff',
    border: 'none',
    borderRadius: '4px',
    fontSize: '12px',
    cursor: 'pointer',
  },
  btnSaveSmall: {
    padding: '4px 10px',
    background: '#16a34a',
    color: '#fff',
    border: 'none',
    borderRadius: '4px',
    fontSize: '12px',
    cursor: 'pointer',
  },
  btnCancelSmall: {
    padding: '4px 10px',
    background: '#94a3b8',
    color: '#fff',
    border: 'none',
    borderRadius: '4px',
    fontSize: '12px',
    cursor: 'pointer',
  },
  loading: {
    padding: '40px',
    textAlign: 'center',
    color: '#64748b',
    fontSize: '16px',
  },
  empty: {
    padding: '40px',
    textAlign: 'center',
    color: '#94a3b8',
    fontSize: '14px',
  },
}
