import serverHttp from '@/api/serverHttp'

export default class Event {

  constructor (userId) {
    this.userId = userId
  }

  async loadUsers (eventId) {
    if (!eventId) return
    const users = await serverHttp.query('/events/lesson_users', {'id': eventId}, false, true)

    if (users.teacher)
      users.teacher.stream = null

    if (users.students && users.students.length)
      users.students.forEach(user => user.stream = null)

    return users
  }

}
